#include "../tp2.h"

float clamp2(float pixel)
{
	float res = pixel < 0.0 ? 0.0 : pixel;
	return res > 1.0 ? 1.0 : res;
}

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
	float al = clamp2(alpha);
	//ciclo
	for (int f = 1; f < filas-1; f++) {
		for (int c = 1; c < cols-1; c++) {
	//pointers
			bgra_t *p_d = (bgra_t*) &dst_matrix[f][c * 4];

			bgra_t *p_sInfIzq = (bgra_t*) &src_matrix[f-1][(c-1) * 4];
			bgra_t *p_sInfAct = (bgra_t*) &src_matrix[f-1][	 c   * 4];
			bgra_t *p_sInfDer = (bgra_t*) &src_matrix[f-1][(c+1) * 4];
			bgra_t *p_sActIzq = (bgra_t*) &src_matrix[ f ][(c-1) * 4];
			bgra_t *p_sActAct = (bgra_t*) &src_matrix[ f ][	 c   * 4];
			bgra_t *p_sActDer = (bgra_t*) &src_matrix[ f ][(c+1) * 4];
			bgra_t *p_sSupIzq = (bgra_t*) &src_matrix[f+1][(c-1) * 4];
			bgra_t *p_sSupAct = (bgra_t*) &src_matrix[f+1][	 c   * 4];
			bgra_t *p_sSupDer = (bgra_t*) &src_matrix[f+1][(c+1) * 4];
	//Valores De Alrededor
			unsigned char valR[9] = { p_sSupIzq->r, p_sSupAct->r, p_sSupDer->r,
					 	      		  p_sActIzq->r, p_sActAct->r, p_sActDer->r,
					 	      		  p_sInfIzq->r, p_sInfAct->r, p_sInfDer->r };

			unsigned char valG[9] = { p_sSupIzq->g, p_sSupAct->g, p_sSupDer->g,
							  		  p_sActIzq->g, p_sActAct->g, p_sActDer->g,
							  		  p_sInfIzq->g, p_sInfAct->g, p_sInfDer->g };

			unsigned char valB[9] = { p_sSupIzq->b, p_sSupAct->b, p_sSupDer->b,
								 	  p_sActIzq->b, p_sActAct->b, p_sActDer->b,
							  		  p_sInfIzq->b, p_sInfAct->b, p_sInfDer->b };
	//inicio maxes		
		 	unsigned char maxR = valR[0];
 			unsigned char maxG = valG[0];
 			unsigned char maxB = valB[0];					
	//seteo maxes		
			for (int i =1; i<9;i++){
				if (maxR<valR[i]) maxR = valR[i];
				if (maxG<valG[i]) maxG = valG[i];
				if (maxB<valB[i]) maxB = valB[i];
			}
	//asigno fies						 
			float fiR = ( (maxR >= maxG && maxR >= maxB) ? 1.0 + al: 1.0 - al );
 			float fiG = ( (maxR <  maxG && maxG >= maxB) ? 1.0 + al: 1.0 - al );
 			float fiB = ( (maxR <  maxB && maxG <  maxB) ? 1.0 + al: 1.0 - al );			
	//asigno destino	
			p_d->r = ((fiR * p_sActAct->r) < 255 ?  0.5+(p_sActAct->r * fiR  ) : 255);
			p_d->g = ((fiG * p_sActAct->g) < 255 ?  0.5+(p_sActAct->g * fiG  ) : 255);
			p_d->b = ((fiB * p_sActAct->b) < 255 ?  0.5+(p_sActAct->b * fiB  ) : 255);
			
		}
	}			



}
