#include <stdio.h>

const char* dgemm_desc = "dgemm using loop unrolling"; // Aqui puedes dar una pequeña descripcion de tu programa

void square_dgemm (int n, float* A, float* B, float* C)
{
  /* For each row i of A */
  for (int i = 0; i < n; i++)
    for (int j = 0; j < n; j+=4)
    { 
      register float aki, cij0, cij1, cij2, cij3;
      
      cij0 = C[i*n+j+0];
      cij1 = C[i*n+j+1];
      cij2 = C[i*n+j+2];
      cij3 = C[i*n+j+3];

      for (int k = 0; k < n; k++) 
      {
	aki = A[k+i*n];
        cij0 += aki * B[j+k*n+0];
        cij1 += aki * B[j+k*n+1];
        cij2 += aki * B[j+k*n+2];
        cij3 += aki * B[j+k*n+3];
      }

      C[i*n+j+0] = cij0;
      C[i*n+j+1] = cij1;
      C[i*n+j+2] = cij2;
      C[i*n+j+3] = cij3;
    }
}
