/*
 * Copyright (c) 2001-2002, David Janssens
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS `AS IS'
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#define TIME_H_NOT_AVAILABLE

#include "tcd.h"
#include "int.h"
#include "t1.h"
#include "t2.h"
#include "dwt.h"
#include "mct.h"
#include <setjmp.h>
#include <float.h>
#include <stdio.h>
#ifndef TIME_H_NOT_AVAILABLE
#include <time.h>
#endif
#include <math.h>
#include <stdlib.h>
#include <string.h>


tcd_image_t tcd_image;

j2k_image_t *tcd_img;
j2k_cp_t *tcd_cp;

tcd_tile_t *tcd_tile;
j2k_tcp_t *tcd_tcp;
int tcd_tileno;

extern jmp_buf j2k_error;

extern void * matlab_ex_data;
extern void * matlab_in_data;

extern void * taille_x_e;
extern void * taille_y_e;



void tcd_dump(tcd_image_t *img) {
    int tileno, compno, resno, bandno, precno, cblkno;
    fprintf(stderr, "image {\n");
    fprintf(stderr, "  tw=%d, th=%d\n", img->tw, img->th);
    for (tileno=0; tileno<img->tw*img->th; tileno++) {
        tcd_tile_t *tile=&tcd_image.tiles[tileno];
        fprintf(stderr, "  tile {\n");
        fprintf(stderr, "    x0=%d, y0=%d, x1=%d, y1=%d, numcomps=%d\n", tile->x0, tile->y0, tile->x1, tile->y1, tile->numcomps);
        for (compno=0; compno<tile->numcomps; compno++) {
            tcd_tilecomp_t *tilec=&tile->comps[compno];
            fprintf(stderr, "    tilec {\n");
            fprintf(stderr, "      x0=%d, y0=%d, x1=%d, y1=%d, numresolutions=%d\n", tilec->x0, tilec->y0, tilec->x1, tilec->y1, tilec->numresolutions);
            for (resno=0; resno<tilec->numresolutions; resno++) {
                tcd_resolution_t *res=&tilec->resolutions[resno];
                fprintf(stderr, "      res {\n");
                fprintf(stderr, "        x0=%d, y0=%d, x1=%d, y1=%d, pw=%d, ph=%d, numbands=%d\n", res->x0, res->y0, res->x1, res->y1, res->pw, res->ph, res->numbands);
                for (bandno=0; bandno<res->numbands; bandno++) {
                    tcd_band_t *band=&res->bands[bandno];
                    fprintf(stderr, "        band {\n");
                    fprintf(stderr, "          x0=%d, y0=%d, x1=%d, y1=%d, stepsize=%d, numbps=%d\n", band->x0, band->y0, band->x1, band->y1, band->stepsize, band->numbps);
                    for (precno=0; precno<res->pw*res->ph; precno++) {
                        tcd_precinct_t *prec=&band->precincts[precno];
                        fprintf(stderr, "          prec {\n");
                        fprintf(stderr, "            x0=%d, y0=%d, x1=%d, y1=%d, cw=%d, ch=%d\n", prec->x0, prec->y0, prec->x1, prec->y1, prec->cw, prec->ch);
                        for (cblkno=0; cblkno<prec->cw*prec->ch; cblkno++) {
                            tcd_cblk_t *cblk=&prec->cblks[cblkno];
                            fprintf(stderr, "            cblk {\n");
                            fprintf(stderr, "              x0=%d, y0=%d, x1=%d, y1=%d\n", cblk->x0, cblk->y0, cblk->x1, cblk->y1);
                            fprintf(stderr, "            }\n");
                        }
                        fprintf(stderr, "          }\n");
                    }
                    fprintf(stderr, "        }\n");
                }
                fprintf(stderr, "      }\n");
            }
            fprintf(stderr, "    }\n");
        }
        fprintf(stderr, "  }\n");
    }
    fprintf(stderr, "}\n");
}

void tcd_init(j2k_image_t *img, j2k_cp_t *cp) {
    int tileno, compno, resno, bandno, precno, cblkno;
    tcd_img=img;
    tcd_cp=cp;
    tcd_image.tw=cp->tw;
    tcd_image.th=cp->th;
    tcd_image.tiles=(tcd_tile_t*)malloc(cp->tw*cp->th*sizeof(tcd_tile_t));
    for (tileno=0; tileno<cp->tw*cp->th; tileno++) {
        j2k_tcp_t *tcp=&cp->tcps[tileno];
        tcd_tile_t *tile=&tcd_image.tiles[tileno];
        int p=tileno%cp->tw;
        int q=tileno/cp->tw;
        tile->x0=int_max(cp->tx0+p*cp->tdx, img->x0);
        tile->y0=int_max(cp->ty0+q*cp->tdy, img->y0);
        tile->x1=int_min(cp->tx0+(p+1)*cp->tdx, img->x1);
        tile->y1=int_min(cp->ty0+(q+1)*cp->tdy, img->y1);

        tile->numcomps=img->numcomps;
        tile->comps=(tcd_tilecomp_t*)malloc(img->numcomps*sizeof(tcd_tilecomp_t));
        for (compno=0; compno<tile->numcomps; compno++) {
            j2k_tccp_t *tccp=&tcp->tccps[compno];
            tcd_tilecomp_t *tilec=&tile->comps[compno];
            tilec->x0=int_ceildiv(tile->x0, img->comps[compno].dx);
            tilec->y0=int_ceildiv(tile->y0, img->comps[compno].dy);
            tilec->x1=int_ceildiv(tile->x1, img->comps[compno].dx);
            tilec->y1=int_ceildiv(tile->y1, img->comps[compno].dy);
            tilec->data=(int*)malloc(sizeof(int)*(tilec->x1-tilec->x0)*(tilec->y1-tilec->y0));
            tilec->numresolutions=tccp->numresolutions;
            tilec->resolutions=(tcd_resolution_t*)malloc(tilec->numresolutions*sizeof(tcd_resolution_t));
            for (resno=0; resno<tilec->numresolutions; resno++) {
                int pdx, pdy;
                int levelno=tilec->numresolutions-1-resno;
                int tlprcxstart, tlprcystart, brprcxend, brprcyend;
                int tlcbgxstart, tlcbgystart, brcbgxend, brcbgyend;
                int cbgwidthexpn, cbgheightexpn;
                int cblkwidthexpn, cblkheightexpn;
                tcd_resolution_t *res=&tilec->resolutions[resno];
                res->x0=int_ceildivpow2(tilec->x0, levelno);
                res->y0=int_ceildivpow2(tilec->y0, levelno);
                res->x1=int_ceildivpow2(tilec->x1, levelno);
                res->y1=int_ceildivpow2(tilec->y1, levelno);
                res->numbands=resno==0?1:3;

                if (tccp->csty&J2K_CCP_CSTY_PRT) {
                    pdx=tccp->prcw[resno];
                    pdy=tccp->prch[resno];
                } else {
                    pdx=15;
                    pdy=15;
                }

                tlprcxstart=int_floordivpow2(res->x0, pdx)<<pdx;
                tlprcystart=int_floordivpow2(res->y0, pdy)<<pdy;
                brprcxend=int_ceildivpow2(res->x1, pdx)<<pdx;
                brprcyend=int_ceildivpow2(res->y1, pdy)<<pdy;
                res->pw=(brprcxend-tlprcxstart)>>pdx;
                res->ph=(brprcyend-tlprcystart)>>pdy;

                if (resno==0) {
                    tlcbgxstart=tlprcxstart;
                    tlcbgystart=tlprcystart;
                    brcbgxend=brprcxend;
                    brcbgyend=brprcyend;
                    cbgwidthexpn=pdx;
                    cbgheightexpn=pdy;
                } else {
                    tlcbgxstart=int_ceildivpow2(tlprcxstart, 1);
                    tlcbgystart=int_ceildivpow2(tlprcystart, 1);
                    brcbgxend=int_ceildivpow2(brprcxend, 1);
                    brcbgyend=int_ceildivpow2(brprcyend, 1);
                    cbgwidthexpn=pdx-1;
                    cbgheightexpn=pdy-1;
                }

                cblkwidthexpn=int_min(tccp->cblkw, cbgwidthexpn);
                cblkheightexpn=int_min(tccp->cblkh, cbgheightexpn);

                for (bandno=0; bandno<res->numbands; bandno++) {
                    int x0b, y0b;
                    int gain, numbps;
                    j2k_stepsize_t *ss;
                    tcd_band_t *band=&res->bands[bandno];
                    band->bandno=resno==0?0:bandno+1;
                    x0b=(band->bandno==1)||(band->bandno==3)?1:0;
                    y0b=(band->bandno==2)||(band->bandno==3)?1:0;

                    if (band->bandno==0) {
                        band->x0=int_ceildivpow2(tilec->x0, levelno);
                        band->y0=int_ceildivpow2(tilec->y0, levelno);
                        band->x1=int_ceildivpow2(tilec->x1, levelno);
                        band->y1=int_ceildivpow2(tilec->y1, levelno);
                    } else {
                        band->x0=int_ceildivpow2(tilec->x0-(1<<levelno)*x0b, levelno+1);
                        band->y0=int_ceildivpow2(tilec->y0-(1<<levelno)*y0b, levelno+1);
                        band->x1=int_ceildivpow2(tilec->x1-(1<<levelno)*x0b, levelno+1);
                        band->y1=int_ceildivpow2(tilec->y1-(1<<levelno)*y0b, levelno+1);
                    }

                    ss=&tccp->stepsizes[resno==0?0:3*(resno-1)+bandno+1];
                    gain=tccp->qmfbid==0?dwt_getgain_real(band->bandno):dwt_getgain(band->bandno);
                    numbps=img->comps[compno].prec+gain;
                    band->stepsize=(int)floor((1.0+ss->mant/2048.0)*pow(2.0,numbps-ss->expn)*8192.0);
                    band->numbps=ss->expn+tccp->numgbits-1; /*  WHY -1 ? */

                    band->precincts=(tcd_precinct_t*)malloc(res->pw*res->ph*sizeof(tcd_precinct_t));

                    for (precno=0; precno<res->pw*res->ph; precno++) {
                        int tlcblkxstart, tlcblkystart, brcblkxend, brcblkyend;
                        int cbgxstart=tlcbgxstart+(precno%res->pw)*(1<<cbgwidthexpn);
                        int cbgystart=tlcbgystart+(precno/res->pw)*(1<<cbgheightexpn);
                        int cbgxend=cbgxstart+(1<<cbgwidthexpn);
                        int cbgyend=cbgystart+(1<<cbgheightexpn);
                        tcd_precinct_t *prc=&band->precincts[precno];
                        prc->x0=int_max(cbgxstart, band->x0);
                        prc->y0=int_max(cbgystart, band->y0);
                        prc->x1=int_min(cbgxend, band->x1);
                        prc->y1=int_min(cbgyend, band->y1);

                        tlcblkxstart=int_floordivpow2(prc->x0, cblkwidthexpn)<<cblkwidthexpn;
                        tlcblkystart=int_floordivpow2(prc->y0, cblkheightexpn)<<cblkheightexpn;
                        brcblkxend=int_ceildivpow2(prc->x1, cblkwidthexpn)<<cblkwidthexpn;
                        brcblkyend=int_ceildivpow2(prc->y1, cblkheightexpn)<<cblkheightexpn;
                        prc->cw=(brcblkxend-tlcblkxstart)>>cblkwidthexpn;
                        prc->ch=(brcblkyend-tlcblkystart)>>cblkheightexpn;

                        prc->cblks=(tcd_cblk_t*)malloc(prc->cw*prc->ch*sizeof(tcd_cblk_t));

                        prc->incltree=tgt_create(prc->cw, prc->ch);
                        prc->imsbtree=tgt_create(prc->cw, prc->ch);

                        for (cblkno=0; cblkno<prc->cw*prc->ch; cblkno++) {
                            int cblkxstart=tlcblkxstart+(cblkno%prc->cw)*(1<<cblkwidthexpn);
                            int cblkystart=tlcblkystart+(cblkno/prc->cw)*(1<<cblkheightexpn);
                            int cblkxend=cblkxstart+(1<<cblkwidthexpn);
                            int cblkyend=cblkystart+(1<<cblkheightexpn);
                            tcd_cblk_t *cblk=&prc->cblks[cblkno];
                            cblk->x0=int_max(cblkxstart, prc->x0);
                            cblk->y0=int_max(cblkystart, prc->y0);
                            cblk->x1=int_min(cblkxend, prc->x1);
                            cblk->y1=int_min(cblkyend, prc->y1);
                        }
                    }
                }
            }
        }
    }
    /*     tcd_dump(&tcd_image); */
}

void tcd_makelayer(int layno, double thresh, int final) {
    int compno, resno, bandno, precno, cblkno, passno;
    for (compno=0; compno<tcd_tile->numcomps; compno++) {
        tcd_tilecomp_t *tilec=&tcd_tile->comps[compno];
        for (resno=0; resno<tilec->numresolutions; resno++) {
            tcd_resolution_t *res=&tilec->resolutions[resno];
            for (bandno=0; bandno<res->numbands; bandno++) {
                tcd_band_t *band=&res->bands[bandno];
                for (precno=0; precno<res->pw*res->ph; precno++) {
                    tcd_precinct_t *prc=&band->precincts[precno];
                    for (cblkno=0; cblkno<prc->cw*prc->ch; cblkno++) {
                        tcd_cblk_t *cblk=&prc->cblks[cblkno];
                        tcd_layer_t *layer=&cblk->layers[layno];
                        int n;
                        if (layno==0) {
                            cblk->numpassesinlayers=0;
                        }
                        n=cblk->numpassesinlayers;
                        for (passno=cblk->numpassesinlayers; passno<cblk->totalpasses; passno++) {
                            int dr;
                            double dd;
                            tcd_pass_t *pass=&cblk->passes[passno];
                            if (n==0) {
                                dr=pass->rate;
                                dd=pass->distortiondec;
                            } else {
                                dr=pass->rate-cblk->passes[n-1].rate;
                                dd=pass->distortiondec-cblk->passes[n-1].distortiondec;
                            }
                            if (dr==0) {
                                if (dd!=0) {
                                    n=passno+1;
                                }
                                continue;
                            }
                            if (dd/dr>thresh) {
                                n=passno+1;
                            }
                        }
                        layer->numpasses=n-cblk->numpassesinlayers;
                        if (!layer->numpasses) {
                            continue;
                        }
                        if (cblk->numpassesinlayers==0) {
                            layer->len=cblk->passes[n-1].rate;
                            layer->data=cblk->data;
                        } else {
                            layer->len=cblk->passes[n-1].rate-cblk->passes[cblk->numpassesinlayers-1].rate;
                            layer->data=cblk->data+cblk->passes[cblk->numpassesinlayers-1].rate;
                        }
                        if (final) {
                            cblk->numpassesinlayers=n;
                        }
                    }
                }
            }
        }
    }
}

void tcd_rateallocate(unsigned char *dest, int len) {
    int compno, resno, bandno, precno, cblkno, passno, layno;
    double min, max;
    min=DBL_MAX;
    max=0;
    for (compno=0; compno<tcd_tile->numcomps; compno++) {
        tcd_tilecomp_t *tilec=&tcd_tile->comps[compno];
        for (resno=0; resno<tilec->numresolutions; resno++) {
            tcd_resolution_t *res=&tilec->resolutions[resno];
            for (bandno=0; bandno<res->numbands; bandno++) {
                tcd_band_t *band=&res->bands[bandno];
                for (precno=0; precno<res->pw*res->ph; precno++) {
                    tcd_precinct_t *prc=&band->precincts[precno];
                    for (cblkno=0; cblkno<prc->cw*prc->ch; cblkno++) {
                        tcd_cblk_t *cblk=&prc->cblks[cblkno];
                        for (passno=0; passno<cblk->totalpasses; passno++) {
                            tcd_pass_t *pass=&cblk->passes[passno];
                            int dr;
                            double dd, rdslope;
                            if (passno==0) {
                                dr=pass->rate;
                                dd=pass->distortiondec;
                            } else {
                                dr=pass->rate-cblk->passes[passno-1].rate;
                                dd=pass->distortiondec-cblk->passes[passno-1].distortiondec;
                            }
                            if (dr==0) {
                                continue;
                            }
                            rdslope=dd/dr;
                            if (rdslope<min) {
                                min=rdslope;
                            }
                            if (rdslope>max) {
                                max=rdslope;
                            }
                        }
                    }
                }
            }
        }
    }
    for (layno=0; layno<tcd_tcp->numlayers; layno++) {
        volatile double lo=min;
        volatile double hi=max;
        volatile int success=0;
        volatile int maxlen=int_min(tcd_tcp->rates[layno], len);
        volatile double goodthresh;
        volatile int goodlen;
        volatile jmp_buf oldenv;
        volatile int i;
        memcpy((void*)oldenv, j2k_error, sizeof(jmp_buf));
        for (i=0; i<32; i++) {
            volatile double thresh=(lo+hi)/2;
            int l;
            tcd_makelayer(layno, thresh, 0);
            if (setjmp(j2k_error)) {
                lo=thresh;
                continue;
            }
            l=t2_encode_packets(tcd_img, tcd_cp, tcd_tileno, tcd_tile, layno+1, dest, maxlen);
        /*             fprintf(stderr, "rate alloc: len=%d, max=%d\n", l, maxlen); */
            hi=thresh;
            success=1;
            goodthresh=thresh;
            goodlen=l;
        }
        memcpy(j2k_error, (void*)oldenv, sizeof(jmp_buf));
        if (!success) {
            longjmp(j2k_error, 1);
        }
        tcd_makelayer(layno, goodthresh, 1);
    }
}

int tcd_encode_tile(int tileno, unsigned char *dest, int len) {


    int taille_x = (int) (*( (int *)taille_x_e));
    int taille_y = (int) (*( (int *)taille_y_e));


    int compno;
    int l;
#ifndef TIME_H_NOT_AVAILABLE
    clock_t time1, time2, time3, time4, time5, time6, time7;
#endif
    tcd_tile_t *tile;
    tcd_tileno=tileno;
    tcd_tile=&tcd_image.tiles[tileno];
    tcd_tcp=&tcd_cp->tcps[tileno];
    tile=tcd_tile;

#ifndef TIME_H_NOT_AVAILABLE
    time7=clock();

    time1=clock();
#endif
    for (compno=0; compno<tile->numcomps; compno++) {
        int i, j;
        int tw, w;
        tcd_tilecomp_t *tilec=&tile->comps[compno];
        /*
          if signed, no adjustment is performed
          if unsigned, subtracting the median value : for example, 2 bits [0..3] -> [-2..1]
        */
        int adjust=tcd_img->comps[compno].sgnd?0:1<<(tcd_img->comps[compno].prec-1);
        tw=tilec->x1-tilec->x0;
        w=int_ceildiv(tcd_img->x1-tcd_img->x0, tcd_img->comps[compno].dx);
        for (j=tilec->y0; j<tilec->y1; j++) {
            for (i=tilec->x0; i<tilec->x1; i++) {
	        #ifndef ENCODE_ONLY
                if (tcd_tcp->tccps[compno].qmfbid==1) {
                    tilec->data[i-tilec->x0+(j-tilec->y0)*tw]=tcd_img->comps[compno].data[i+j*w]-adjust;
                } else if (tcd_tcp->tccps[compno].qmfbid==0) {
                    /* conversion to FIXED is performed for real calculations only */
                    tilec->data[i-tilec->x0+(j-tilec->y0)*tw]=(tcd_img->comps[compno].data[i+j*w]-adjust)<<13;
		}
		#endif
		#ifdef ENCODE_ONLY
			tilec->data[i-tilec->x0+(j-tilec->y0)*tw]= (int) ((*((double*)matlab_in_data + i + j*taille_x))*(1<<13));
		#endif
	   }
        }
    }
#ifndef TIME_H_NOT_AVAILABLE
    time1=clock()-time1;

    time2=clock();
#endif
#ifndef ENCODE_ONLY
    if (tcd_tcp->mct) {
        if (tcd_tcp->tccps[0].qmfbid==0) {
            mct_encode_real(tile->comps[0].data, tile->comps[1].data, tile->comps[2].data, (tile->comps[0].x1-tile->comps[0].x0)*(tile->comps[0].y1-tile->comps[0].y0));
        } else {
            mct_encode(tile->comps[0].data, tile->comps[1].data, tile->comps[2].data, (tile->comps[0].x1-tile->comps[0].x0)*(tile->comps[0].y1-tile->comps[0].y0));
        }
    }
#endif
#ifndef TIME_H_NOT_AVAILABLE
    time2=clock()-time2;

    time3=clock();
#endif
#ifndef ENCODE_ONLY
    for (compno=0; compno<tile->numcomps; compno++) { 
        tcd_tilecomp_t *tilec=&tile->comps[compno];
        if (tcd_tcp->tccps[compno].qmfbid==1) {
            dwt_encode(tilec->data, tilec->x1-tilec->x0, tilec->y1-tilec->y0, tilec->numresolutions-1);
        } else if (tcd_tcp->tccps[compno].qmfbid==0)
        {	    dwt_encode_real(tilec->data, tilec->x1-tilec->x0, tilec->y1-tilec->y0, tilec->numresolutions-1);
        }
		    memcpy((int*) matlab_ex_data, (int*) tilec->data ,taille_x*taille_y*sizeof(int));
    }
#endif
#ifndef TIME_H_NOT_AVAILABLE
    time3=clock()-time3;

    time4=clock();
#endif
    t1_init_luts();
/*	fprintf(stderr, "taille des codeblocks : %d %d, type codage codeblocks : %d\n", tcd_tcp->tccps->cblkw, tcd_tcp->tccps->cblkh, tcd_tcp->tccps->cblksty);
	fprintf(stderr, "taille des precincts : %d %d\n", tcd_tcp->tccps->prcw , tcd_tcp->tccps->prch);
	fprintf(stderr, "Pas de quantif.(exposant/mantisse) : %d %d\n", tcd_tcp->tccps->stepsizes->expn,tcd_tcp->tccps->stepsizes->mant);
*/
    t1_encode_cblks(tile, tcd_tcp);
#ifndef TIME_H_NOT_AVAILABLE
    time4=clock()-time4;

    time5=clock();
#endif
    tcd_rateallocate(dest, len);
#ifndef TIME_H_NOT_AVAILABLE
    time5=clock()-time5;

    time6=clock();
#endif
    l=t2_encode_packets(tcd_img, tcd_cp, tileno, tile, tcd_tcp->numlayers, dest, len);
#ifndef TIME_H_NOT_AVAILABLE
    time6=clock()-time6;

    time7=clock()-time7;
#endif

    /*     printf("tile encoding times:\n"); */
    /*     printf("img->tile: %d.%.3d s\n", time1/CLOCKS_PER_SEC, (time1%CLOCKS_PER_SEC)*1000/CLOCKS_PER_SEC); */
    /*       printf("mct:       %d.%.3d s\n", time2/CLOCKS_PER_SEC, (time2%CLOCKS_PER_SEC)*1000/CLOCKS_PER_SEC); */
    /*     printf("dwt:       %d.%.3d s\n", time3/CLOCKS_PER_SEC, (time3%CLOCKS_PER_SEC)*1000/CLOCKS_PER_SEC); */
    /*     printf("tier 1:    %d.%.3d s\n", time4/CLOCKS_PER_SEC, (time4%CLOCKS_PER_SEC)*1000/CLOCKS_PER_SEC); */
    /*     printf("ratealloc: %d.%.3d s\n", time5/CLOCKS_PER_SEC, (time5%CLOCKS_PER_SEC)*1000/CLOCKS_PER_SEC); */
    /*     printf("tier 2:    %d.%.3d s\n", time6/CLOCKS_PER_SEC, (time6%CLOCKS_PER_SEC)*1000/CLOCKS_PER_SEC); */
    /*     printf("total:     %d.%.3d s\n", time7/CLOCKS_PER_SEC, (time7%CLOCKS_PER_SEC)*1000/CLOCKS_PER_SEC); */

    return l;
}

int tcd_decode_tile(unsigned char *src, int len, int tileno) {

    #ifdef ENCODE_ONLY
    int taille_x = (int) (*( (int *)taille_x_e));
    int taille_y = (int) (*( (int *)taille_y_e));
    #endif

    int l;
    int compno;
    int eof=0;
    jmp_buf oldenv;
#ifndef TIME_H_NOT_AVAILABLE
    clock_t time1, time2, time3, time4, time5, time6;
#endif

    tcd_tile_t *tile;
    tcd_tileno=tileno;
    tcd_tile=&tcd_image.tiles[tileno];
    tcd_tcp=&tcd_cp->tcps[tileno];
    tile=tcd_tile;

#ifndef TIME_H_NOT_AVAILABLE
    time6=clock();

    time1=clock();
#endif
    memcpy(oldenv, j2k_error, sizeof(jmp_buf));
    if (setjmp(j2k_error)) {
        eof=1;
    /*         fprintf(stderr, "tcd_decode: incomplete bistream\n"); */
    } else {
        l=t2_decode_packets(src, len, tcd_img, tcd_cp, tileno, tile);
    }
    memcpy(j2k_error, oldenv, sizeof(jmp_buf));
#ifndef TIME_H_NOT_AVAILABLE
    time1=clock()-time1;

    time2=clock();
#endif
    t1_init_luts();
    t1_decode_cblks(tile, tcd_tcp);
#ifndef TIME_H_NOT_AVAILABLE
    time2=clock()-time2;

    time3=clock();
#endif
#ifndef ENCODE_ONLY
    for (compno=0; compno<tile->numcomps; compno++) {
        tcd_tilecomp_t *tilec=&tile->comps[compno];
        if (tcd_tcp->tccps[compno].qmfbid==1) {
            dwt_decode(tilec->data, tilec->x1-tilec->x0, tilec->y1-tilec->y0, tilec->numresolutions-1);
        } else if (tcd_tcp->tccps[compno].qmfbid==0) {
            dwt_decode_real(tilec->data, tilec->x1-tilec->x0, tilec->y1-tilec->y0, tilec->numresolutions-1);
        }
    }
#endif
#ifndef TIME_H_NOT_AVAILABLE
    time3=clock()-time3;

    time4=clock();
#endif
#ifndef ENCODE_ONLY
    if (tcd_tcp->mct) {
        if (tcd_tcp->tccps[0].qmfbid==0) {
            mct_decode_real(tile->comps[0].data, tile->comps[1].data, tile->comps[2].data, (tile->comps[0].x1-tile->comps[0].x0)*(tile->comps[0].y1-tile->comps[0].y0));
        } else {
            mct_decode(tile->comps[0].data, tile->comps[1].data, tile->comps[2].data, (tile->comps[0].x1-tile->comps[0].x0)*(tile->comps[0].y1-tile->comps[0].y0));
        }
    }
#endif
#ifndef TIME_H_NOT_AVAILABLE
    time4=clock()-time4;

    time5=clock();
#endif

    for (compno=0; compno<tile->numcomps; compno++) {
        tcd_tilecomp_t *tilec=&tile->comps[compno];
        int adjust=tcd_img->comps[compno].sgnd?0:1<<(tcd_img->comps[compno].prec-1);
        int min=tcd_img->comps[compno].sgnd?-(1<<(tcd_img->comps[compno].prec-1)):0;
        int max=tcd_img->comps[compno].sgnd?(1<<(tcd_img->comps[compno].prec-1))-1:(1<<tcd_img->comps[compno].prec)-1;
        int tw=tilec->x1-tilec->x0;
        int w=int_ceildiv(tcd_img->x1-tcd_img->x0, tcd_img->comps[compno].dx);
        int i, j;
        for (j=tilec->y0; j<tilec->y1; j++) {
            for (i=tilec->x0; i<tilec->x1; i++) {
                int v;
	#ifdef ENCODE_ONLY
		int v_back;
		v_back =tilec->data[i-tilec->x0+(j-tilec->y0)*tw];
	#endif

                if (tcd_tcp->tccps[compno].qmfbid==1) {
                    v=tilec->data[i-tilec->x0+(j-tilec->y0)*tw];
                } else if (tcd_tcp->tccps[compno].qmfbid==0) {
                    v=tilec->data[i-tilec->x0+(j-tilec->y0)*tw]>>13;
                }
	#ifdef ENCODE_ONLY
			*((double*)matlab_ex_data + i +j*taille_x) = (((double) (v_back))/((double) (1<<13))) ;
	#endif
                v+=adjust;
                tcd_img->comps[compno].data[i+j*w]=int_clamp(v, min, max);

            }
        }

    }
#ifndef TIME_H_NOT_AVAILABLE
    time5=clock()-time5;

    time6=clock()-time6;
#endif

    /*     printf("tile decoding times:\n"); */
    /*     printf("tier 2:    %d.%.3d s\n", time1/CLOCKS_PER_SEC, (time1%CLOCKS_PER_SEC)*1000/CLOCKS_PER_SEC); */
    /*     printf("tier 1:    %d.%.3d s\n", time2/CLOCKS_PER_SEC, (time2%CLOCKS_PER_SEC)*1000/CLOCKS_PER_SEC); */
    /*     printf("dwt:       %d.%.3d s\n", time3/CLOCKS_PER_SEC, (time3%CLOCKS_PER_SEC)*1000/CLOCKS_PER_SEC); */
    /*     printf("mct:       %d.%.3d s\n", time4/CLOCKS_PER_SEC, (time4%CLOCKS_PER_SEC)*1000/CLOCKS_PER_SEC); */
    /*     printf("tile->img: %d.%.3d s\n", time5/CLOCKS_PER_SEC, (time5%CLOCKS_PER_SEC)*1000/CLOCKS_PER_SEC); */
    /*     printf("total:     %d.%.3d s\n", time6/CLOCKS_PER_SEC, (time6%CLOCKS_PER_SEC)*1000/CLOCKS_PER_SEC); */

    if (eof) {
        longjmp(j2k_error, 1);
    }
    return l;
}
