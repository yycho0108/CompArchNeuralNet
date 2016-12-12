module add_float
  #(parameter
   FLOAT_WIDTH = 64
  )
  (
  input wire rst_n, clk, start,
  input wire op_sub, //high for subtraction, low for addition
  input wire [FLOAT_WIDTH - 1: 0] op1, op2,
  output reg [FLOAT_WIDTH - 1: 0] out_reg,
  output reg nan_reg,
  output reg overflow_reg,
  output reg underflow_reg,
  output reg zero_reg,
  output reg done_reg
  );
  localparam EXP_WIDTH = (FLOAT_WIDTH == 64) ? 11: 8; 
  localparam FRACTION_WIDTH = (FLOAT_WIDTH == 64) ? 52: 23;
  localparam FULL_FRACTION_WIDTH = FRACTION_WIDTH + 3;
  localparam SIGN_BIT =  FLOAT_WIDTH - 1;
  localparam EXP_MSB = SIGN_BIT - 1;
  localparam EXP_LSB = EXP_MSB - EXP_WIDTH + 1;
  localparam EXP_MAX = (2 ** (EXP_WIDTH)) - 1;
  localparam FRACTION_MSB = EXP_LSB - 1;
  localparam NAN_VALUE = (FLOAT_WIDTH == 64) ? 64'hFFF8_0000_0000_0000: 32'hFFC0_0000;
  localparam INF_VALUE = (FLOAT_WIDTH == 64) ? 64'h7FF0_0000_0000_0000: 32'h7F80_0000;
  localparam ZERO_DATA_WIDTH = 7;
  localparam STAGES = 6; // пока неизвестно кол-во стадий
  localparam STAGES_WIDTH = 3;
  //-----------

  reg [STAGES_WIDTH - 1: 0] stage;
  wire [STAGES_WIDTH - 1: 0] next_stage = (stage < STAGES - 1'b1)? stage + 1'b1: 0;
  always@(posedge clk or negedge rst_n)
  begin
    //stage increment
	if(start)
	begin
	  stage <= 0;  
	end
	else
	begin
	  stage <= next_stage;
	end
  end

  wire [EXP_WIDTH - 1: 0] exp1 = op1[EXP_MSB: EXP_LSB],
    exp2 = op2[EXP_MSB: EXP_LSB];
	
  wire [FRACTION_WIDTH - 1: 0] frac1 = op1[FRACTION_MSB: 0],
    frac2 = op2[FRACTION_MSB: 0];
  
  wire exp1_bigger = exp1 > exp2, 
  exp2_bigger = exp1 < exp2,
  frac2_bigger = frac1 < frac2, 
  sign1 = op1[SIGN_BIT],
  sign2 = op2[SIGN_BIT];

  wire real_op = sign1 ^ sign2 ^ op_sub,
  swap = (exp1 == exp2) && frac2_bigger || exp2_bigger;
  
  reg [FLOAT_WIDTH - 1: 0] left_op_reg, right_op_reg;
    
  always@(posedge clk or negedge rst_n)
  begin
    if(stage == 0)
	 begin
	   if(swap)
		begin
	     left_op_reg <= op2;
	     right_op_reg <= op1;
	   end
		else
		begin
	     left_op_reg <= op1;
	     right_op_reg <= op2;
	   end
	   done_reg <= 1'b0;
	 end
  end
//----------------------  
  wire [FRACTION_WIDTH - 1: 0] left_frac = left_op_reg[FRACTION_WIDTH - 1: 0];
  wire [EXP_WIDTH - 1: 0] left_exp = left_op_reg[EXP_MSB: EXP_LSB];
  wire [FRACTION_WIDTH - 1: 0] right_frac = right_op_reg[FRACTION_WIDTH - 1: 0];
  wire [EXP_WIDTH - 1: 0] right_exp = right_op_reg[EXP_MSB: EXP_LSB];
  wire right_sign = right_op_reg[SIGN_BIT],
  left_sign = left_op_reg[SIGN_BIT];
  wire left_is_nan = &left_exp && (left_frac != 0),
  right_is_nan = &right_exp && (right_frac != 0),
  left_is_inf = &left_exp && (left_frac == 0),
  right_is_inf = &right_exp && (right_frac == 0),
  left_is_zero = left_exp == 0,
  right_is_zero = right_exp == 0;
  
  reg [FULL_FRACTION_WIDTH - 1: 0] frac_left_wide_reg, frac_right_wide_reg;
  
  always@(posedge clk or negedge rst_n)
  begin
    if(stage == 1)
	begin
     frac_left_wide_reg <= left_is_zero? 0: {2'b01, left_frac, 1'b0};
	  frac_right_wide_reg <= right_is_zero? 0: {2'b01, right_frac, 1'b0} >> (left_exp - right_exp/* + op2_correction*/);
	end
  end
//-----------
  reg [FULL_FRACTION_WIDTH - 1: 0] result_frac_before_correction_reg;
	  
  always@(posedge clk or negedge rst_n)
  begin
    if(stage == 2)
	begin
	  if(real_op == 0)
	  begin
	    result_frac_before_correction_reg <= frac_left_wide_reg + frac_right_wide_reg;
     end
	  else
	  begin
	    result_frac_before_correction_reg <= frac_left_wide_reg - frac_right_wide_reg;
	  end
	end
  end

  reg [FULL_FRACTION_WIDTH - 1: 0] frac_before_rounding_reg;
  reg [EXP_WIDTH + 1: 0] result_exp_reg;
  wire [ZERO_DATA_WIDTH - 1: 0] zero_count = zero_cnt(result_frac_before_correction_reg[FULL_FRACTION_WIDTH - 1: 0]),
  exp_correction1 = (zero_count == 0)? 0: zero_count - 1;
  wire exp_correction2 = result_frac_before_correction_reg[FULL_FRACTION_WIDTH - 1];
  
  always@(posedge clk or negedge rst_n)
  begin
    if(stage == 3)
    begin
	   frac_before_rounding_reg <= (result_frac_before_correction_reg << exp_correction1) >> exp_correction2;
		result_exp_reg <= left_exp - exp_correction1 + exp_correction2;
	 end
  end
 
  reg [FULL_FRACTION_WIDTH - 1: 0] result_frac_reg;
	
  always@(posedge clk or negedge rst_n)
  begin
    if(stage == 4)  //rounding
	 begin
	   result_frac_reg <= frac_before_rounding_reg + 1'b1;
	 end
  end	 
  
  wire is_nan_result = left_is_nan || right_is_nan || (left_is_inf && right_is_inf && real_op),
  is_overflow_result = result_exp_reg[EXP_WIDTH] && !result_exp_reg[EXP_WIDTH - 1],
  is_inf_result = !is_nan_result && (left_is_inf || right_is_inf || is_overflow_result),
  is_zero = result_frac_reg[FRACTION_WIDTH: 2] == 0,
  is_underflow_result = !is_zero && (result_exp_reg[EXP_WIDTH] || (result_exp_reg[EXP_WIDTH - 1: 0] == 0)),
  result_sign = left_sign ^ (swap && op_sub);
  
  always@(posedge clk or negedge rst_n)
  begin
    if(stage == 5)
	 begin
	   if(is_nan_result)
		begin
        out_reg <= NAN_VALUE;		  
		  nan_reg <= 1'b1;
        overflow_reg <= 1'b0;
        underflow_reg <= 1'b0;
        zero_reg <= 1'b0;
		end
		else if(is_inf_result)
		begin
		  out_reg <= INF_VALUE | (result_sign << SIGN_BIT);	  
		  nan_reg <= 1'b0;
        overflow_reg <= 1'b0;
        underflow_reg <= 1'b0;
        zero_reg <= 1'b0;
		end
	   else if(is_underflow_result)
		begin
		  out_reg <= result_sign << SIGN_BIT;
		  nan_reg <= 1'b0;
        overflow_reg <= 1'b0;
        underflow_reg <= 1'b1;
        zero_reg <= 1'b0;
		end
		else if(is_zero)
		begin
		  out_reg <= result_sign << SIGN_BIT;
		  nan_reg <= 1'b0;
        overflow_reg <= 1'b0;
        underflow_reg <= 1'b0;
        zero_reg <= 1'b1;
		end
		else
		begin
		  out_reg <= {result_sign, result_exp_reg[EXP_WIDTH - 1: 0], result_frac_reg[FRACTION_WIDTH: 1]};
		  nan_reg <= 1'b0;
        overflow_reg <= 1'b0;
        underflow_reg <= 1'b0;
        zero_reg <= 1'b0;
		end
	   done_reg <= 1'b1;
	 end
  end
  
function [ZERO_DATA_WIDTH - 1: 0] zero_cnt;
input [FRACTION_WIDTH + 2: 0] in;
integer i;
begin
  zero_cnt = FRACTION_WIDTH + 3;
  for(i = FRACTION_WIDTH + 2; i >= 0; i = i - 1)
  begin
    if(in[i] && zero_cnt == FRACTION_WIDTH + 3)
	   zero_cnt = FRACTION_WIDTH - i + 2;
  end
end
endfunction

endmodule
