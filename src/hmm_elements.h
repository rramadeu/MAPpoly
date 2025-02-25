#ifndef HMM_ELEMENTS_H
#define HMM_ELEMENTS_H

std::vector <double>  emit_poly(int m, int cte, int ip_k, int ip_k1,
                                int iq_k, int iq_k1,
                                std::vector<int>& p,
                                std::vector<int>& q,
                                std::vector<double>& g);

std::vector<std::vector<double> > transition(int m, double rf);

double prob_k1_given_k_l_m(int m, int l, double rf);

std::vector<double> forward(int m,
                            std::vector<double>& fk,
                            std::vector<int>& ik,
                            std::vector<int>& ik1,
                            std::vector<std::vector<double> >& T);

std::vector<double> backward(int m,
                             std::vector<double>& fk1,
                             std::vector<int>& ik,
                             std::vector<int>& ik1,
                             std::vector<std::vector<double> >& T);


std::vector<long double> forward_highprec(int m,
				     std::vector<long double>& fk,
				     std::vector<int>& ik,
				     std::vector<int>& ik1,
				     std::vector<std::vector<double> >& T);

std::vector<long double> backward_highprec(int m,
				      std::vector<long double>& fk1,
				      std::vector<int>& ik,
				      std::vector<int>& ik1,
				      std::vector<std::vector<double> >& T);

std::vector<std::vector<int> > index_func(int m,
                                             std::vector<int>& p,
                                             std::vector<int>& q);

std::vector<std::vector<double> > rec_num(int m);

std::vector<std::vector<int> > rec_num_no_denominator(int m);

double init_poly(int m, int dP, int dQ, int dG);

#endif
