
#include "../tp2.h"

void smalltiles_c (unsigned char *src, unsigned char *dst, int cols, int filas, int src_row_size, int dst_row_size) {
	//COMPLETAR
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;
	
	for (int f = 0; f < filas/2; f++) {
		for (int c = 0; c < cols; c++) {
			bgra_t *p_d0 = (bgra_t*) &dst_matrix[f][c * 4];
			bgra_t *p_d1 = (bgra_t*) &dst_matrix[filas/2 + f][c * 4];
            bgra_t *p_s = (bgra_t*) &src_matrix[2*f][2*c * 4];

			p_d0->b = p_s->b;
			p_d0->g = p_s->g;
			p_d0->r = p_s->r;
			p_d0->a = p_s->a;
		
			p_d1->b = p_s->b;
			p_d1->g = p_s->g;
			p_d1->r = p_s->r;
			p_d1->a = p_s->a;
		}
	}
}

