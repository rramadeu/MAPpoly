#' Compute genotype conditional probabilities using global error
#'
#' Conditional probabilities are calculeted for each marker.
#' In this version, the probabilities are not calculated bewtween
#' markers.
#'
#' @param input.map An object of class \code{mappoly.map}
#'
#' @param phase.config which phase configuration should be used.
#'    "best" will use the one with highest likelihood
#'    
#' @param error global error rate
#'
#' @param verbose if \code{TRUE}, current progress is shown; if
#'     \code{FALSE}, no output is produced.
#'
#' @param ... currently ignored
#'
#' @return An object of class 'mappoly.genoprob'
#' @examples
#'  \dontrun{
#'     data(tetra.solcap)
#'     s1<-make_seq_mappoly(tetra.solcap, 'seq1')
#'     red.mrk<-elim_redundant(s1)
#'     s1.unique.mrks<-make_seq_mappoly(red.mrk)
#'     counts.web<-cache_counts_twopt(s1.unique.mrks, get.from.web = TRUE)
#'     s1.pairs<-est_pairwise_rf(input.seq = s1.unique.mrks,
#'                                   count.cache = counts.web,
#'                                   n.clusters = 10,
#'                                   verbose=TRUE)
#'     unique.gen.ord<-get_genomic_order(s1.unique.mrks)
#'     
#'     ## Selecting a subset of 100 markers at the beginning of chromosome 1 
#'     s1.gen.subset<-make_seq_mappoly(tetra.solcap, rownames(unique.gen.ord)[1:100])
#'     
#'     system.time(s1.gen.subset.map <- est_rf_hmm_sequential(input.seq = s1.gen.subset,
#'                                         start.set = 10,
#'                                         thres.twopt = 10, 
#'                                         thres.hmm = 10,
#'                                         extend.tail = 50,
#'                                         info.tail = TRUE, 
#'                                         twopt = s1.pairs,
#'                                         sub.map.size.diff.limit = 10, 
#'                                         phase.number.limit = 40,
#'                                         reestimate.single.ph.configuration = TRUE,
#'                                         tol = 10e-3,
#'                                         tol.final = 10e-4))
#'      plot(s1.gen.subset.map)
#'      s1.gen.subset.map.error<-est_full_hmm_with_global_error(input.map = s1.gen.subset.map, 
#'                                                                  error = 0.05, 
#'                                                                  verbose = TRUE)
#'      plot(s1.gen.subset.map.error)                                                            
#'                                         
#'      probs<-calc_genoprob(input.map = s1.gen.subset.map.error,
#'                                 verbose = TRUE)
#'      probs.error<-calc_genoprob_error(input.map = s1.gen.subset.map.error,
#'                                 error = 0.05,
#'                                 verbose = TRUE)
#'    op<-par(mfrow = c(1:2))
#'    ## Example: individual 11
#'    ind<-11   
#'    ## posterior probabilities with no error modeling
#'    pr1<-probs$probs[,,ind]
#'    d1<-probs$map
#'    image(t(pr1),
#'          col=RColorBrewer::brewer.pal(n=9 , name = "YlOrRd"),
#'          axes=FALSE,
#'          xlab = "Markers",
#'          ylab = " ",
#'          main = paste("LG_1, ind ", ind))
#'    axis(side = 1, at = d1/max(d1),
#'         labels =rep("", length(d1)), las=2)
#'    axis(side = 2, at = seq(0,1,length.out = nrow(pr1)),
#'         labels = rownames(pr1), las=2, cex.axis=.5)
#'    
#'    ## posterior probabilities with error modeling
#'    pr2<-probs.error$probs[,,ind]
#'    d2<-probs.error$map
#'    image(t(pr2),
#'          col=RColorBrewer::brewer.pal(n=9 , name = "YlOrRd"),
#'          axes=FALSE,
#'          xlab = "Markers",
#'          ylab = " ",
#'          main = paste("LG_1, ind ", ind, " - w/ error "))
#'    axis(side = 1, at = d2/max(d2),
#'         labels =rep("", length(d2)), las=2)
#'    axis(side = 2, at = seq(0,1,length.out = nrow(pr2)),
#'         labels = rownames(pr2), las=2, cex.axis=.5)
#'    par(op)
#'  }
#' @author Marcelo Mollinari, \email{mmollin@ncsu.edu}
#'
#' @references
#'     Mollinari, M., and Garcia, A.  A. F. (2018) Linkage
#'     analysis and haplotype phasing in experimental autopolyploid
#'     populations with high ploidy level using hidden Markov
#'     models, _submited_. \url{https://doi.org/10.1101/415232}
#'
#' @export calc_genoprob_error
#'
calc_genoprob_error<-function(input.map,  phase.config = "best", error = 0.01, verbose = TRUE)
{
  if (!inherits(input.map, "mappoly.map")) {
    stop(deparse(substitute(input.map)), " is not an object of class 'mappoly.map'")
  }
  ## choosing the linkage phase configuration
  LOD.conf <- get_LOD(input.map, sorted = FALSE)
  if(phase.config == "best") {
    i.lpc <- which.min(LOD.conf)
  } else if (phase.config > length(LOD.conf)) {
    stop("invalid linkage phase configuration")
  } else i.lpc <- phase.config
 
  output.seq<-input.map
  mrknames<-get(input.map$info$data.name, pos=1)$mrk.names[input.map$maps[[1]]$seq.num]
  ## 
  geno.temp<-get(input.map$info$data.name, pos=1)$geno.dose[mrknames,]
  indnames<-get(input.map$info$data.name, pos=1)$ind.names
  gen<-vector("list", length(indnames))
  names(gen)<-indnames
  mrk<-ind<-NULL
  dp<-get(input.map$info$data.name, pos=1)$dosage.p[input.map$maps[[1]]$seq.num]
  dq<-get(input.map$info$data.name, pos=1)$dosage.q[input.map$maps[[1]]$seq.num]
  names(dp)<-names(dq)<-mrknames
  for(i in names(gen))
  {
    a<-matrix(0, nrow(geno.temp), input.map$info$m+1, dimnames = list(mrknames, 0:input.map$info$m))
    for(j in rownames(a)){
      if(geno.temp[j,i] == input.map$info$m+1){
        a[j,]<-segreg_poly(m = input.map$info$m, dP = dp[j], dQ = dq[j])
      } else {
        a[j,geno.temp[j,i]+1]<-1          
      }
    }
    a.temp<-t(a)
    if(!is.null(error))
      a.temp<-apply(a.temp, 2, genotyping_global_error, error=error, th.prob = 0.9)
    gen[[i]]<-a.temp
  }
  g <- as.double(unlist(gen))
  m = as.numeric(input.map$info$m)
  n.mrk = as.numeric(input.map$info$n.mrk)
  n.ind = as.numeric(length(gen))
  p = as.numeric(unlist(input.map$maps[[i.lpc]]$seq.ph$P))
  dp = as.numeric(cumsum(c(0, sapply(input.map$maps[[1]]$seq.ph$P, function(x) sum(length(x))))))
  q = as.numeric(unlist(input.map$maps[[1]]$seq.ph$Q))
  dq = as.numeric(cumsum(c(0, sapply(input.map$maps[[1]]$seq.ph$Q, function(x) sum(length(x))))))
  rf = as.double(input.map$maps[[i.lpc]]$seq.rf)
  res.temp <-
    .Call(
      "calc_genoprob_prior",
      as.numeric(m),
      as.numeric(n.mrk),
      as.numeric(n.ind),
      as.numeric(p),
      as.numeric(dp),
      as.numeric(q),
      as.numeric(dq),
      as.double(g),
      as.double(rf),
      as.numeric(rep(0, choose(m, m/2)^2 * n.mrk * n.ind)),
      as.double(0),
      as.numeric(verbose),
      PACKAGE = "mappoly"
    )
  cat("\n")
  dim(res.temp[[1]])<-c(choose(m,m/2)^2,n.mrk,n.ind)
  dimnames(res.temp[[1]])<-list(kronecker(apply(combn(letters[1:m],m/2),2, paste, collapse=""),
                                          apply(combn(letters[(m+1):(2*m)],m/2),2, paste, collapse=""), paste, sep=":"),
                                mrknames, indnames)
  structure(list(probs = res.temp[[1]], map = create_map(input.map)), class="mappoly.genoprob")
}
