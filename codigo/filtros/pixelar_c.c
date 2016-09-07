
#include "../tp2.h"

void pixelar_c (
	unsigned char *src, 
	unsigned char *dst, 
	int cols, 
	int filas, 
	int src_row_size, 
	int dst_row_size
) {
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

	//COMPLETAR

		/*	Funcion que vamos a usar siempre para recorrer en c:

		for (int f = 0; f < filas; f++) {
			for (int c = 0; c < cols; c++) {
				bgra_t *p_d = (bgra_t*) &dst_matrix[f][c * 4];
				bgra_t *p_s = (bgra_t*) &src_matrix[f][c * 4];

				p_d->b = p_s->b;
				p_d->g = p_s->g;
				p_d->r = p_s->r;
				p_d->a = p_s->a;
			}
		}			
	*/
		for (int f = 0; f < filas-1; f=f+2) {
			for (int c = 0; c < cols-1; c=c+2) {
				bgra_t *p_d = (bgra_t*) &dst_matrix[f][c * 4];

				bgra_t *p_d0 = (bgra_t*) &dst_matrix[f    ][  c   * 4];
				bgra_t *p_d1 = (bgra_t*) &dst_matrix[f + 1][(c+1) * 4];
				bgra_t *p_d2 = (bgra_t*) &dst_matrix[f    ][  c   * 4];
				bgra_t *p_d3 = (bgra_t*) &dst_matrix[f + 1][(c+1) * 4];


				bgra_t *p_s0 = (bgra_t*) &src_matrix[f    ][  c   * 4];
				bgra_t *p_s1 = (bgra_t*) &src_matrix[f + 1][(c+1) * 4];
				bgra_t *p_s2 = (bgra_t*) &src_matrix[f    ][  c   * 4];
				bgra_t *p_s3 = (bgra_t*) &src_matrix[f + 1][(c+1) * 4];

				//promedios
				unsigned char bi = (p_s0->b + p_s1->b + p_s2->b + p_s3->b)/4;
				unsigned char gi = (p_s0->g + p_s1->g + p_s2->g + p_s3->g)/4;
				unsigned char ri = (p_s0->r + p_s1->r + p_s2->r + p_s3->r)/4;

				p_d0->b = bi;
				p_d0->g = gi;
				p_d0->r = ri;

				p_d1->b = bi;
				p_d1->g = gi;
				p_d1->r = ri;

				p_d2->b = bi;
				p_d2->g = gi;
				p_d2->r = ri;

				p_d3->b = bi;
				p_d3->g = gi;
				p_d3->r = ri;
			}
		}


}
