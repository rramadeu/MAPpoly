% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/group.R
\name{group_mappoly}
\alias{group_mappoly}
\alias{print.mappoly.group}
\alias{plot.mappoly.group}
\title{Assign markers to linkage groups}
\usage{
group_mappoly(input.mat, input.seq = NULL, expected.groups = NULL,
  inter = TRUE, comp.mat = FALSE, verbose = TRUE)

\method{print}{mappoly.group}(x, detailed = TRUE, ...)

\method{plot}{mappoly.group}(x, ...)
}
\arguments{
\item{input.mat}{an object of class \code{mappoly.rf.matrix}.}

\item{input.seq}{an object of class \code{mappoly.sequence}.
It must be contained in 'input.mat'}

\item{expected.groups}{the number of expected groups for the species (if any)}

\item{inter}{if \code{TRUE}, plots a dendrogram with highlighting the
expected groups before continue.}

\item{comp.mat}{if \code{TRUE}, show a comparison between the reference
based and the linkage based grouping, if the sequence information is
present}

\item{verbose}{logical. If \code{TRUE}, current progress is shown;
if \code{FALSE}, no output is produced.}

\item{x}{an object of class onemap.segreg.test}

\item{detailed}{logical. If \code{TRUE} the markers in each
linkage group are printed.}

\item{...}{currently ignored}
}
\value{
Returns an object of class \code{mappoly.group}, which is a list
    containing the following components:
    \item{i}{...}
    \item{ii}{...}
}
\description{
Identifies linkage groups of markers, using results from two-point
(pairwise) analysis.
}
\examples{
 \dontrun{
    data(hexafake)
    all.mrk <- make_seq_mappoly(hexafake, 'all')
    red.mrk <- elim_redundant(all.mrk)
    unique.mrks <- make_seq_mappoly(red.mrk)
    counts <- cache_counts_twopt(unique.mrks, get.from.web = TRUE)
    all.pairs <- est_pairwise_rf(input.seq = unique.mrks,
                                 count.cache = counts,
                                 n.clusters = 16,
                                 verbose=TRUE)

    ## Full recombination fraction matrix
    mat.full<-rf_list_to_matrix(input.twopt=all.pairs)
    plot(mat.full)

    lgs <- group_mappoly(input.mat = mat.full,
                         input.seq = unique.mrks,
                         expected.groups = 3,
                         inter = TRUE,
                         comp.mat = TRUE, #this data has physical information
                         verbose = TRUE)
    lgs
    plot(lgs)
    lg1 <- make_seq_mappoly(lgs, 1)
    lg2 <- make_seq_mappoly(lgs, 2)
    lg3 <- make_seq_mappoly(lgs, 3)

    ##Plot matrices
    m1<-make_mat_mappoly(input.seq = lg1, input.mat = mat.full)
    m2<-make_mat_mappoly(input.seq = lg2, input.mat = mat.full)
    m3<-make_mat_mappoly(input.seq = lg3, input.mat = mat.full)
    op<-par(mfrow = c(1,3), pty = "s")
    plot(m1, main.text = "LG1")
    plot(m2, main.text = "LG2")
    plot(m3, main.text = "LG3")
    par(op)
   }
}
\references{
Mollinari, M., and Garcia, A.  A. F. (2018) Linkage
    analysis and haplotype phasing in experimental autopolyploid
    populations with high ploidy level using hidden Markov
    models, _submited_. \url{https://doi.org/10.1101/415232}
}
\author{
Marcelo Mollinari, \email{mmollin@ncsu.edu}
}
\keyword{internal}
