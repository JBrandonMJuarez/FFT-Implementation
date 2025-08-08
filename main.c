#define CHIP_6713
#include <dsk6713.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// TODO: Incluir archivos .h. Al menos el que contiene los senos y cosenos. Se puede llevar a ensamblador
#define N  8



typedef struct{
    double  real[N];
    double  imag[N];
} complex;


double x_real[N] = {0.814723686393179, 0.905791937075619, 0.126986816293506, 0.913375856139019, 0.632359246225410, 0.0975404049994095, 0.278498218867048, 0.546881519204984};
//double x_real[N] = {0,0,0,0,0,0,0,0};
double x_imag[N] = {0,0,0,0,0,0,0,0};
double X_real[N] = {0,0,0,0,0,0,0,0};
double X_imag[N] = {0,0,0,0,0,0,0,0};


complex fft_n (double x_in[], int Nn);



int main(void)
{
    DSK6713_init();
    double x[N] = {0.814723686393179, 0.905791937075619, 0.126986816293506, 0.913375856139019, 0.632359246225410, 0.0975404049994095, 0.278498218867048, 0.546881519204984};
    complex X;
    //FFTn(&x_real,&x_imag,&X_real,&X_imag,N,3);
    //memcpy(X.real, X_real, sizeof(X_real));
    //memcpy(X.imag, X_imag, sizeof(x_imag));
    X = fft_n(x,N);
    while(1);
}

complex fft_n (double x_in[], int Nn){
    complex X_out;
    memcpy(x_real, x_in, sizeof(x_real));
    memset(x_imag, 0, sizeof(x_imag));
    memset(X_real, 0, sizeof(X_real));
    memset(X_imag, 0, sizeof(X_imag));


    FFTn(&x_real,&x_imag,&X_real,&X_imag,Nn,3);

    memcpy(X_out.real, X_real, sizeof(X_real));
    memcpy(X_out.imag, X_imag, sizeof(x_imag));
    return X_out;

}

