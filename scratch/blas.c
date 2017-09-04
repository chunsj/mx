#include <cblas.h>
#include <stdio.h>

int
main () {
  int i = 0;
  double A[9] = {1.0,2.0,1.0,-3.0,4.0,-1.0,1.0,1.0,1.0};
  double B[9] = {1.0,2.0,1.0,-3.0,4.0,-1.0,1.0,1.0,1.0};
  double C[12] = {.5,.5,.5,.5,.5,.5,.5,.5,.5,.5,.5,.5};
  cblas_dgemm(CblasColMajor, CblasNoTrans, CblasTrans,3,3,2,1,A, 3, B, 3,2,C,3);

  for (i = 0; i < 100000000; i++)
    cblas_dgemm(CblasColMajor, CblasNoTrans, CblasTrans,3,3,2,1,A, 3, B, 3,0,C,3);

  for(i = 0; i < 9; i++)
    printf("%lf ", C[i]);
  printf("\n");

  return 0;
}
