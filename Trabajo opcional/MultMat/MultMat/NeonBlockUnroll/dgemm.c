#include <arm_neon.h>
#define UNROLL 4
#define BLOCKSIZE 32 

const char* dgemm_desc = "dgemm using cache blocking, unrolling and Neon intrinsics"; // Aqui puedes dar una pequeña descripcion de tu programa

void do_block (int n, int si, int sj, int sk,
float *A, float *B, float *C)
{
  for ( int i = si; i < si+BLOCKSIZE; i++ )
    for ( int j = sj; j < sj+BLOCKSIZE; j+=4*UNROLL )
    {
      float32x4_t c[UNROLL];
      for ( int x = 0; x < UNROLL; x++ )
        c[x] = vld1q_f32(C+i*n+x*4+j);

      for( int k = sk; k < sk+BLOCKSIZE; k++ )
      {   
         for (int x = 0; x < UNROLL; x++)
          c[x] = vmlaq_n_f32( c[x],
                              vld1q_f32(B+j+k*n+x*4),
                              (float32_t) *(A+k+i*n));
      }
      for ( int x = 0; x < UNROLL; x++ )
        vst1q_f32(C+i*n+x*4+j, c[x]);
   }
}

void square_dgemm (int n, float* A, float* B, float* C)
{ 
  for ( int sj = 0; sj < n; sj += BLOCKSIZE )
    for ( int si = 0; si < n; si += BLOCKSIZE )
      for ( int sk = 0; sk < n; sk += BLOCKSIZE )
        do_block(n, si, sj, sk, A, B, C);
}
