#include <stdlib.h> // For: exit, drand48, malloc, free, NULL, EXIT_FAILURE
#include <stdio.h>  // For: perror
#include <string.h> // For: memset

#ifdef GETTIMEOFDAY
#include <sys/time.h> // For struct timeval, gettimeofday
#else
#include <time.h> // For struct timespec, clock_gettime, CLOCK_MONOTONIC
#endif

/* Your function must have the following signature: */
extern const char* dgemm_desc;
extern void square_dgemm (int, float*, float*, float*);

/* Auxiliary functions */

double wall_time ()
{
#ifdef GETTIMEOFDAY
  struct timeval t;
  gettimeofday (&t, NULL);
  return 1.*t.tv_sec + 1.e-6*t.tv_usec;
#else
  struct timespec t;
  clock_gettime (CLOCK_MONOTONIC, &t);
  return 1.*t.tv_sec + 1.e-9*t.tv_nsec;
#endif
}

void die (const char* message)
{
  perror (message);
  exit (EXIT_FAILURE);
}

/* This routine performs a reference dgemm operation to check correctness
 *  C := C + A * B
 * where A, B, and C are lda-by-lda matrices stored in row-major format.
 * On exit, A and B maintain their input values. */    
void ref_square_dgemm (int n, float* A, float* B, float* C)
{
  /* For each row i of A */
  for (int i = 0; i < n; ++i)
    /* For each column j of B */
    for (int j = 0; j < n; ++j) 
    {
      /* Compute C(i,j) */
      float cij = C[i*n+j]; /* cij = C[i][j] */
      for( int k = 0; k < n; k++ )
	cij += A[k+i*n] * B[j+k*n]; /* cij += A[i][k]*B[k][j] */
      C[i*n+j] = cij;   /*C[i][j] = cij*/
    }
}

void check_correctness (int n, float* A, float *B, float* C, float* Cref)
{
  float dif = 0, max_error = 0.00001;
  ref_square_dgemm(n, A, B, Cref);
  for ( int x = 0; x < n*n; x++ )
    dif += abs(C[x]-Cref[x]);
  if ( dif > max_error )
    printf("Bad multiplication routine, absolute error: %f\n", dif);

}

void fill (float* p, int n)
{
  for (int i = 0; i < n; ++i)
    p[i] =  ((float)rand()/(float)RAND_MAX)*2 - 1; // Uniformly distributed over [-1, 1]
}

void flush_cache()
{
  int bigsize = 10000000;
  float *clr = NULL;
  clr = (float *)  calloc(bigsize,sizeof(float));
  if (clr == NULL) die ("failed to allocate buffer");
  fill( clr, bigsize);
}

/* The benchmarking program */
int main (int argc, char **argv)
{
  double seconds = 0;
  int n = 512;

  if ( argc > 1 ) n = atoi(argv[1]);

  printf ("Description:\t%s on matrices of size %d x %d\n\n", dgemm_desc, n, n);

  /* allocate memory */
  float* buf = NULL;
  buf = (float*) malloc (4 * n * n * sizeof(float));
  if (buf == NULL) die ("failed to allocate matrices");

  /* set pointers */
  float* A = buf + 0;
  float* B = A + n*n;
  float* C = B + n*n;
  float* Cref = C + n*n;

  srand(time(NULL)); /* getting a new seed*/
  fill (A, n*n);
  fill (B, n*n);
  fill (C, n*n);
  memcpy (Cref, C, n*n*sizeof(float));

  seconds = wall_time();
  square_dgemm (n, A, B, C);
  seconds = wall_time() - seconds;
  printf("Time %e s\n", seconds);


//  check_correctness(n, A, B, C, Cref);
  free (buf);

  return 0;
}
