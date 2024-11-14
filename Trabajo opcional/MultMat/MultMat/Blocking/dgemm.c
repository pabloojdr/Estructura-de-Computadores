#include <stdio.h>
#define BLOCKSIZE 16

const char* dgemm_desc = "dgemm using cache blocking"; // Aqui puedes dar una pequeña descripcion de tu programa

void do_block (int n, int si, int sj, int sk,
float *A, float *B, float *C)
{
  for ( int i = si; i < si+BLOCKSIZE; i++ )
    for ( int j = sj; j < sj+BLOCKSIZE; j++ )
    {
      float cij = C[i*n+j]; /* cij = C[i][j] */
      for( int k = sk; k < sk+BLOCKSIZE; k++ )
        cij += A[k+i*n] * B[j+k*n]; /* cij += A[i][k]*B[k][j] */
      C[i*n+j] = cij;   /*C[i][j] = cij*/
   }
}

void square_dgemm (int n, float* A, float* B, float* C)
{ 
  if ( n < BLOCKSIZE )
  {
    printf("matrix size should be larger than blocksize\n");
    return;
  }

  for ( int sj = 0; sj < n; sj += BLOCKSIZE )
    for ( int si = 0; si < n; si += BLOCKSIZE )
      for ( int sk = 0; sk < n; sk += BLOCKSIZE )
        do_block(n, si, sj, sk, A, B, C);
}
