long N = 4;
long RESULT;

long pow2(long n) 
{
    // IF N == 0 RET 1 (Basisfall)
    // TST.L D0
    // BEQ .Ret_Base
    if (n == 0) {
        // .Ret_Base
        // MOVE.L #1,20(A7)
        return 1;
    } 
    // IF N > 0 
    else {
        // SUBI.L #1,D0
        // MOVE.L D0,-(A7)
        // BSR Pow2
        // MOVE.L (A7)+,D1
        long recursive_result = pow2(n - 1);
        
        // MOVE.L #2,D0
        // MULU.W D0,D1
        // MOVE.L D1,20(A7)
        return 2 * recursive_result;
    }
    
    // .Ret
    // UNLK A5
    // MOVE.L (A7)+,D1
    // MOVE.L (A7)+,D0
    // RTS
    // (All das passiert automatisch, wenn die C-Funktion endet)
}

void main() 
{
    // MOVE.L N,-(A7)
    // BSR Pow2
    // MOVE.L (SP)+,D0
    // MOVE.L D0,RESULT
    RESULT = pow2(N);

    // MOVE.L #9,D1
    // TRAP #15
}