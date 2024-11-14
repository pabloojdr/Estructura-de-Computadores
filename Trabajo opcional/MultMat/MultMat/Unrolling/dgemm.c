#include <stdio.h>
#define UNROLL 4 

const char* dgemm_desc = "dgemm using loop unrolling"; // Aqui puedes dar una pequeña descripcion de tu programa

void square_dgemm (int n, float* A, float* B, float* C)
{
  /* For each row i of A */
  for (int i = 0; i < n; i++)
    for (int j = 0; j < n; j+=UNROLL)
    { 
      float cij[UNROLL];
      for (int x = 0; x < UNROLL; x++)
        cij[x] = C[i*n+j+x];

      for (int k = 0; k < n; k++) 
      {
        for (int x = 0; x < UNROLL; x++)
          cij[x] += A[k+i*n] * B[j+k*n+x];
      }

      for (int x = 0; x < UNROLL; x++)
        C[i*n+j+x] = cij[x];
    }
}
