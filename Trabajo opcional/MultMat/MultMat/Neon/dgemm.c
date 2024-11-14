#include <arm_neon.h>
const char* dgemm_desc = "dgemm with C intrinsics for ARM NEON.";

void square_dgemm (int n, float* A, float* B, float* C)
{
  /* For each row i of A */
  for (int i = 0; i < n; i++){
    for (int j = 0; j < n; j+=4){ 
      float32x4_t c0 = vld1q_f32(C+i*n+j); /* c0 = C[i][j] */
      for (int k = 0; k < n; k++) 
        c0 = vmlaq_n_f32( c0, /* c0 += A[i][k]*B[k][j] */
                    vld1q_f32(B+j+k*n),
                    (float32_t) *(A+k+i*n));
      vst1q_f32(C+i*n+j, c0); /* C[i][j] = c0 */
    }
  }
}
