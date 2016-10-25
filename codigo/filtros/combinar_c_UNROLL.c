
#include "../tp2.h"

float clamp(float pixel)
{
	float res = pixel < 0.0 ? 0.0 : pixel;
	return res > 255.0 ? 255 : res;
}

void combinar_c (
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

	//COMPLETAR
	//voltear_horizontal
		for (int f = 0; f<filas; f++) {
			for (int c = 0; c<cols; c+=2) {
				bgra_t *p_d = (bgra_t*) &dst_matrix[f][(cols-c-1) * 4];
				bgra_t *p_s = (bgra_t*) &src_matrix[f][c * 4];
				p_d->b = p_s->b;
				p_d->g = p_s->g;
				p_d->r = p_s->r;
				p_d->a = p_s->a;
				bgra_t *p_d2 = (bgra_t*) &dst_matrix[f][(cols-(c+1)-1) * 4];
				bgra_t *p_s2 = (bgra_t*) &src_matrix[f][(c+1) * 4];
				p_d2->b = p_s2->b;
				p_d2->g = p_s2->g;
				p_d2->r = p_s2->r;
				p_d2->a = p_s2->a;
				/*bgra_t *p_d3 = (bgra_t*) &dst_matrix[f][(cols-(c+2)-1) * 4];
				bgra_t *p_s3 = (bgra_t*) &src_matrix[f][(c+2) * 4];
				p_d3->b = p_s3->b;
				p_d3->g = p_s3->g;
				p_d3->r = p_s3->r;
				p_d3->a = p_s3->a;
				bgra_t *p_d4 = (bgra_t*) &dst_matrix[f][(cols-(c+3)-1) * 4];
				bgra_t *p_s4 = (bgra_t*) &src_matrix[f][(c+3) * 4];
				p_d4->b = p_s4->b;
				p_d4->g = p_s4->g;
				p_d4->r = p_s4->r;
				p_d4->a = p_s4->a;*/
			}
		}
	//Combinar
		float al = clamp(alpha);
		for (int f = 0; f<filas; f++) {
			for (int c = 0; c<cols; c+=2) {
				bgra_t *p_d = (bgra_t*) &dst_matrix[f][c * 4];
				bgra_t *p_s = (bgra_t*) &src_matrix[f][c * 4];
				p_d->b = ( ( al* ( p_d->b - p_s->b) ) / 255.0 ) + p_s->b;
				p_d->g = ( ( al* ( p_d->g - p_s->g) ) / 255.0 ) + p_s->g;
				p_d->r = ( ( al* ( p_d->r - p_s->r) ) / 255.0 ) + p_s->r;
				bgra_t *p_d2 = (bgra_t*) &dst_matrix[f][(c+1) * 4];
				bgra_t *p_s2 = (bgra_t*) &src_matrix[f][(c+1) * 4];
				p_d2->b = ( ( al* ( p_d2->b - p_s2->b) ) / 255.0 ) + p_s->b;
				p_d2->g = ( ( al* ( p_d2->g - p_s2->g) ) / 255.0 ) + p_s->g;
				p_d2->r = ( ( al* ( p_d2->r - p_s2->r) ) / 255.0 ) + p_s->r;
				/*bgra_t *p_d3 = (bgra_t*) &dst_matrix[f][(c+2) * 4];
				bgra_t *p_s3 = (bgra_t*) &src_matrix[f][(c+2) * 4];
				p_d3->b = ( ( al* ( p_d3->b - p_s3->b) ) / 255.0 ) + p_s->b;
				p_d3->g = ( ( al* ( p_d3->g - p_s3->g) ) / 255.0 ) + p_s->g;
				p_d3->r = ( ( al* ( p_d3->r - p_s3->r) ) / 255.0 ) + p_s->r;
				bgra_t *p_d4 = (bgra_t*) &dst_matrix[f][(c+3) * 4];
				bgra_t *p_s4 = (bgra_t*) &src_matrix[f][(c+3) * 4];
				p_d4->b = ( ( al* ( p_d4->b - p_s4->b) ) / 255.0 ) + p_s->b;
				p_d4->g = ( ( al* ( p_d4->g - p_s4->g) ) / 255.0 ) + p_s->g;
				p_d4->r = ( ( al* ( p_d4->r - p_s4->r) ) / 255.0 ) + p_s->r;*/
			}
		}			
}