
SUBROUTINE jacobi_iteration
	USE typedef, only: n_var,A,b,y,L,U,D,R,M,solution,i_row,i_col
	USE algorithm_control, ONLY: iter,Err_limit
	IMPLICIT NONE
	INTERFACE
		REAL(8) FUNCTION norm_vec_inf(diff_solution)
			IMPLICIT NONE
			REAL(8),ALLOCATABLE :: diff_solution(:)
		END FUNCTION
	END INTERFACE
	INTEGER :: i_i,i_r,i_c
	REAL(8),ALLOCATABLE :: solution_old(:),diff_solution(:)

	!read in martrix
	CALL read_matrix_jacobi
	
	ALLOCATE(solution_old(n_var),diff_solution(n_var))
	!initiate x_0
	solution=0.0d0

	L=0.0d0
	D=0.0d0
	U=0.0d0
	M=0.0d0
	R=0.0d0
	y=0.0d0

	!A=L+D+U
	FORALL (i_r=1:n_var,i_c=1:n_var,i_r<i_c) U(i_r,i_c)=A(i_r,i_c) !upper triangular
	FORALL (i_r=1:n_var,i_c=1:n_var,i_r==i_c) D(i_r,i_c)=A(i_r,i_c) !diagonal
	FORALL (i_r=1:n_var,i_c=1:n_var,i_r>i_c) L(i_r,i_c)=A(i_r,i_c) !lower triangular
	
	CALL invert_matrix(D,M)
	R=(L+U)
	y=MATMUL(M,b)
	
	DO i_i=1,iter
		solution_old=solution
		solution=y-MATMUL(MATMUL(M,R),solution_old)
		WRITE(*,"('iter=',I6)") i_i
		WRITE(*,"('   x1,                     x2,                     ...')")
		WRITE(*,*) solution(1),solution(2)
		diff_solution=solution-solution_old
		IF (norm_vec_inf(diff_solution)<Err_limit) THEN
			WRITE(*,"('Converged')")
			EXIT
		ELSEIF (norm_vec_inf(diff_solution)>1d31) THEN
			WRITE(*,"('Diverged')")
			EXIT
		ENDIF
	ENDDO
	
END SUBROUTINE jacobi_iteration
