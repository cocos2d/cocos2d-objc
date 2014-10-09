#import "CCMatrix4.h"

#if __CC_PLATFORM_ANDROID

#include <string.h>



static inline float get(const CCMatrix4 *pIn, int row, int col)
{
    return pIn->m[row + 4*col];
}

static inline void set(CCMatrix4 *pIn, int row, int col, float value)
{
    pIn->m[row + 4*col] = value;
}

static inline void swap(CCMatrix4 *pIn, int r1, int c1, int r2, int c2)
{
    float tmp = get(pIn,r1,c1);
    set(pIn,r1,c1,get(pIn,r2,c2));
    set(pIn,r2,c2, tmp);
}

static inline bool gaussj(CCMatrix4 *a, CCMatrix4 *b)
{
    int i, icol = 0, irow = 0, j, k, l, ll, n = 4, m = 4;
    float big, dum, pivinv;
    int indxc[n];
    int indxr[n];
    int ipiv[n];
    
    for (j = 0; j < n; j++) {
        ipiv[j] = 0;
    }
    
    for (i = 0; i < n; i++) {
        big = 0.0f;
        for (j = 0; j < n; j++) {
            if (ipiv[j] != 1) {
                for (k = 0; k < n; k++) {
                    if (ipiv[k] == 0) {
                        if (fabs(get(a,j, k)) >= big) {
                            big = fabs(get(a,j, k));
                            irow = j;
                            icol = k;
                        }
                    }
                }
            }
        }
        ++(ipiv[icol]);
        if (irow != icol) {
            for (l = 0; l < n; l++) {
                swap(a,irow, l, icol, l);
            }
            for (l = 0; l < m; l++) {
                swap(b,irow, l, icol, l);
            }
        }
        indxr[i] = irow;
        indxc[i] = icol;
        if (get(a,icol, icol) == 0.0) {
            return false;
        }
        pivinv = 1.0f / get(a,icol, icol);
        set(a,icol, icol, 1.0f);
        for (l = 0; l < n; l++) {
            set(a,icol, l, get(a,icol, l) * pivinv);
        }
        for (l = 0; l < m; l++) {
            set(b,icol, l, get(b,icol, l) * pivinv);
        }
        
        for (ll = 0; ll < n; ll++) {
            if (ll != icol) {
                dum = get(a,ll, icol);
                set(a,ll, icol, 0.0f);
                for (l = 0; l < n; l++) {
                    set(a,ll, l, get(a,ll, l) - get(a,icol, l) * dum);
                }
                for (l = 0; l < m; l++) {
                    set(b,ll, l, get(a,ll, l) - get(b,icol, l) * dum);
                }
            }
        }
    }
    
    for (l = n - 1; l >= 0; l--) {
        if (indxr[l] != indxc[l]) {
            for (k = 0; k < n; k++) {
                swap(a,k, indxr[l], k, indxc[l]);
            }
        }
    }
    return true;
}

CCMatrix4 CCMatrix4Invert(CCMatrix4 matrix, bool *isInvertible) {
    CCMatrix4 inv;
    CCMatrix4 tmp;
    
    memcpy(&inv, &matrix, sizeof(CCMatrix4));
    memcpy(&tmp, &CCMatrix4Identity, sizeof(CCMatrix4));
    
    bool invertable = gaussj(&inv, &tmp);
    if (isInvertible)
    {
        *isInvertible = invertable;
    }
    
    return inv;
}

#endif

