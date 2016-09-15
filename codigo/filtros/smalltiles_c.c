
#include "../tp2.h"

void smalltiles_c (unsigned char *src, unsigned char *dst, int cols, int filas, int src_row_size, int dst_row_size) {
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;
		
		//tercer // cuarto
		//primer // segundo

	for (int f = 0; f < filas/2; f++) {
		for (int c = 0; c < cols/2; c++) {
			bgra_t *p_d0 = (bgra_t*) &dst_matrix[f][c * 4]; 							//primer
			bgra_t *p_d1 = (bgra_t*) &dst_matrix[f][((cols*4)/2) + c * 4];				//segundo
			bgra_t *p_d2 = (bgra_t*) &dst_matrix[(filas/2) + f][c * 4];  				//tercer
			bgra_t *p_d3 = (bgra_t*) &dst_matrix[(filas/2) + f][((cols*4)/2) + c * 4];	//cuarto

            bgra_t *p_s = (bgra_t*) &src_matrix[2*f][2*c * 4];
            
			p_d0->b = p_s->b;
			p_d0->g = p_s->g;
			p_d0->r = p_s->r;
			p_d0->a = p_s->a;		
		
			p_d1->b = p_s->b;
			p_d1->g = p_s->g;
			p_d1->r = p_s->r;
			p_d1->a = p_s->a;

			p_d2->b = p_s->b;
			p_d2->g = p_s->g;
			p_d2->r = p_s->r;
			p_d2->a = p_s->a;

			p_d3->b = p_s->b;
			p_d3->g = p_s->g;
			p_d3->r = p_s->r;
			p_d3->a = p_s->a;		
		}
	}
}

