
#include "../tp2.h"


void colorizar_c (
	unsigned char *src,
	unsigned char *dst,
	int cols,
	int filas,
	int src_row_size,
	int dst_row_size,
	float alpha
) {
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

	// TODO: Implementar


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
}
