module addition (s3, e3, m3, s1, s2, e1, e2, m1, m2);
      
output s3;
output [7:0] e3;
output [22:0] m3;
input s1, s2;
input [7:0] e1, e2;
input [22:0] m1, m2;   

wire  s3;   
wire [7:0] e3;   
wire [22:0] m3; 
wire diff;
wire [3:0] count;
wire [7:0] mbuff6,counter;
wire [24:0] mbuff1, mbuff2, mbuff3,mbuff4,mbuff5;


assign diff = (e1 > e2) ? 1'b1 : 
		(e2 > e1) ?  1'b0 :
		(m1 > m2) ? 1'b1 : 1'b0;  

assign s3 = (s1==s2) ? s1:
            (diff==1'b1) ? s1: s2;
  
       
assign counter = (diff == 0) ? e2 - e1 :  e1 - e2;
assign mbuff1 =  (diff == 0) ? {2'b01,m1} : {2'b01,m2};
assign mbuff3 =  (diff == 0) ? {2'b01,m2} : {2'b01,m1};
assign mbuff6 =  (diff == 0) ? (e2 - 8'b01111111) : (e1 - 8'b01111111); 

assign   mbuff2 = mbuff1>>counter;

 
assign    mbuff4 = (s1==s2) ?  (mbuff2 + mbuff3) : (mbuff3 - mbuff2);

           
assign mbuff5= (mbuff4[24]==1) ? (mbuff4 << 1'b1):
               (mbuff4[23]==1) ? (mbuff4 << 2'b10):
               (mbuff4[22]==1) ? (mbuff4 << 2'b11):
               (mbuff4[21]==1) ? (mbuff4 << 3'b100):
	       (mbuff4[20]==1) ? (mbuff4 << 3'b101):	
 	       (mbuff4[19]==1) ? (mbuff4 << 3'b110):
   	       (mbuff4[18]==1) ? (mbuff4 << 3'b111):
	       (mbuff4[17]==1) ? (mbuff4 << 4'b1000):
	       (mbuff4[16]==1) ? (mbuff4 << 4'b1001):
	       (mbuff4[15]==1) ? (mbuff4 << 4'b1010):
 	       (mbuff4[14]==1) ? (mbuff4 << 4'b1011):
               (mbuff4[13]==1) ? (mbuff4 << 4'b1100):
	       (mbuff4[12]==1) ? (mbuff4 << 4'b1101):
 	       (mbuff4[11]==1) ? (mbuff4 << 4'b1110):
  	       (mbuff4[10]==1) ? (mbuff4 << 4'b1111):
	       (mbuff4[9]==1) ? (mbuff4 << 5'b10000):
               (mbuff4[8]==1) ? (mbuff4 << 5'b10001):
	       (mbuff4[7]==1) ? (mbuff4 << 5'b10010):
 	       (mbuff4[6]==1) ? (mbuff4 << 5'b10011):
 	       (mbuff4[5]==1) ? (mbuff4 << 5'b10100):
               (mbuff4[4]==1) ? (mbuff4 << 5'b10101):
	       (mbuff4[3]==1) ? (mbuff4 << 5'b10110):
               (mbuff4[2]==1) ? (mbuff4 << 5'b10111):
               (mbuff4[1]==1) ? (mbuff4 << 5'b11000):
               (mbuff4[0]==1) ? (mbuff4 << 1): 25'b0000000000000000000000000;



assign e3= (mbuff4[24]==1) ? (mbuff6 + 8'b10000000):
           (mbuff4[23]==1) ? (mbuff6 + 8'b01111111):
           (mbuff4[22]==1) ? (mbuff6 + 8'b01111111 - 1'b1):
           (mbuff4[21]==1) ? (mbuff6 + 8'b01111111 - 2'b10):
           (mbuff4[20]==1) ? (mbuff6 + 8'b01111111 - 2'b11):
           (mbuff4[19]==1) ? (mbuff6 + 8'b01111111 - 3'b100):
           (mbuff4[18]==1) ? (mbuff6 + 8'b01111111 - 3'b101):
           (mbuff4[17]==1) ? (mbuff6 + 8'b01111111 - 3'b110):
           (mbuff4[16]==1) ? (mbuff6 + 8'b01111111 - 3'b111):
           (mbuff4[15]==1) ? (mbuff6 + 8'b01111111 - 4'b1000):
           (mbuff4[14]==1) ? (mbuff6 + 8'b01111111 - 4'b1001):
           (mbuff4[13]==1) ? (mbuff6 + 8'b01111111 - 4'b1010):      
           (mbuff4[12]==1) ? (mbuff6 + 8'b01111111 - 4'b1011):
           (mbuff4[11]==1) ? (mbuff6 + 8'b01111111 - 4'b1100):
           (mbuff4[10]==1) ? (mbuff6 + 8'b01111111 - 4'b1101):
           (mbuff4[9]==1) ? (mbuff6 + 8'b01111111 - 4'b1110):
           (mbuff4[8]==1) ? (mbuff6 + 8'b01111111 - 4'b1111):
           (mbuff4[7]==1) ? (mbuff6 + 8'b01111111 - 5'b10000):
           (mbuff4[6]==1) ? (mbuff6 + 8'b01111111 - 5'b10001):
           (mbuff4[5]==1) ? (mbuff6 + 8'b01111111 - 5'b10010):
           (mbuff4[4]==1) ? (mbuff6 + 8'b01111111 - 5'b10011):
           (mbuff4[3]==1) ? (mbuff6 + 8'b01111111 - 5'b10100): 
           (mbuff4[2]==1) ? (mbuff6 + 8'b01111111 - 5'b10101):
           (mbuff4[1]==1) ? (mbuff6 + 8'b01111111 - 5'b10110):
           (mbuff4[0]==1) ? (mbuff6 + 8'b01111111 - 5'b10111):8'b00000000;

assign m3= mbuff5[24:2];

endmodule
  

module multiplication (s3, e3, m3, s1, s2, e1, e2, m1, m2);

output s3;
output [7:0] e3;
output [22:0] m3;
input s1, s2; 
input [7:0] e1, e2; 
input [22:0] m1, m2;

wire [7:0] mbuff2, mbuff3,mbuff4, count;
wire [23:0] imply1, imply2;
wire [47:0] mbuff1, mbuff5; 

assign mbuff3= e1-8'b01111111;
assign mbuff4= e2-8'b01111111;

assign mbuff2= mbuff3 + mbuff4;

assign imply1= {1'b1,m1};
assign imply2= {1'b1,m2};

assign mbuff1= imply1 * imply2;       

assign count= ( mbuff1[47] == 1) ?  8'b00000001 : 8'b00000010;

assign mbuff5= mbuff1 << count;         

assign e3 = (e1==8'b00000000) ? 8'b00000000:
            (e2==8'b00000000) ? 8'b00000000:mbuff2 - count +8'b00000010+8'b01111111;

assign m3 = (e1==8'b00000000) ? 23'b0000000000000000000000: 
            (e2==8'b00000000) ? 23'b0000000000000000000000:mbuff5 [47:25];

assign s3 = (e1==8'b00000000) ? 1'b0:
            (e1==8'b00000000) ? 1'b0: s1 ^ s2;                   

endmodule


module compare (flag, s1, s2, e1, e2, m1, m2);

output [2:0] flag;
input s1, s2;
input [7:0] e1, e2;
input [22:0] m1, m2;

wire [1:0] sign, exp, mag;                                   

assign sign= {s1,s2};

assign exp= (e1 > e2) ? 2'b10:
            (e2 > e1) ? 2'b01: 2'b00;

assign mag= (exp == 2'b00) ? ((m1 > m2) ? 2'b10:
                                (m2 > m1) ? 2'b01: 2'b00): 2'b11;
                                    



assign flag= (sign == 2'b00) ? ((exp == 2'b10) ? 3'b100:
                                (exp == 2'b01) ? 3'b001:
       				(mag == 2'b10) ? 3'b100:
				(mag == 2'b01) ? 3'b001:3'b010):
             (sign == 2'b11) ? ((exp == 2'b10) ? 3'b001:
                                (exp == 2'b01) ? 3'b100: 
                                (mag == 2'b10) ? 3'b001:
                                (mag == 2'b01) ? 3'b100:3'b010):
             (sign == 2'b10) ? 3'b100 : 3'b001;                    


endmodule

module modulo32 (s2, e2, m2, s1, e1, m1);

output s2;
output [7:0] e2;
output [22:0] m2;
input s1;
input [7:0] e1;
input [22:0] m1;

wire [7:0] mbuff3, count;
wire [23:0] imp1,imp2 ,imp3 ,imp4 ,imp5 ,imp6 ,n1 ,n2;                  

assign s2=s1;
assign mbuff3= e1-8'b01111111;
assign imp1= {1'b1,m1};

assign count= (mbuff3 > 8'b00010111) ? (mbuff3 - 8'b00010111):
                                       (8'b00010111 - mbuff3);

assign imp2= (mbuff3 > 8'b00010111) ? (imp1 << count):(imp1 >> count);

assign n1= (mbuff3[7] == 1'b1) ? 24'b000000000000000000000000 : 
                                (24'b000000000000000000011111 & imp2);

assign e2= (n1[4] == 1) ? 8'b10000011:
           (n1[3] == 1) ? 8'b10000010: 
           (n1[2] == 1) ? 8'b10000001:
           (n1[1] == 1) ? 8'b10000000:
           (n1[0] == 1) ? 8'b01111111: 8'b00000000; 

assign n2= (n1[4] == 1) ? n1 << 8'b00010011:
           (n1[3] == 1) ? n1 << 8'b00010100:
           (n1[2] == 1) ? n1 << 8'b00010101:
           (n1[1] == 1) ? n1 << 8'b00010110:
           (n1[0] == 1) ? n1 << 8'b00010111: 24'b000000000000000000000000;


assign m2= n2[22:0];

endmodule


module round (s2, e2, m2, s1, e1, m1);

output s2;
output [7:0] e2;
output [22:0] m2;
input s1;
input [7:0] e1;
input [22:0] m1;

wire mbuff1,mbuff2;
wire [7:0] mbuff3, count, X, w;
wire [23:0] imp1,imp2,imp3,imp4,imp5,imp6,imp7,a;
                              

assign mbuff3= (e1 - 8'b01111111);

assign imp1= {1'b1,m1};

assign count = (8'b00010111 - mbuff3);

assign imp2 = imp1 >> (count-8'b00000001);

assign imp3= imp2 & 24'b00000000000000000000001;

assign imp4= imp2 >> 1;

assign imp5= imp4 + imp3;

assign   X = mbuff3+ 8'b00000001;

assign  w= ( (mbuff3< 8'b00010111) & ( imp5[X]== 1'b1) ) ?  (mbuff3 +8'b00000001 + 8'b01111111 ) :
           ( (mbuff3< 8'b00010111) & ( imp5[X]== 1'b0) ) ?  (mbuff3 +8'b01111111) : e1;

assign imp6 = ( (mbuff3< 8'b00010111) & ( imp5[X]== 1'b1) ) ?
                (imp5 << count- 8'b00000001):
             ( (mbuff3< 8'b00010111) & ( imp5[X]== 1'b0) ) ? ( imp5<<count): imp5;


assign a = ( (mbuff3< 8'b00010111) & ( imp5[X]== 1'b0) ) ?  imp6[22:0]:
            ( (mbuff3< 8'b00010111) & ( imp5[X]==1'b0) ) ? imp6[22:0]:m1;


assign s2= (e1 < 8'b01111110) ? 1'b0: s1;

assign e2= (e1 < 8'b01111110) ? 8'b00000000: w;

assign m2= (e1 < 8'b01111110) ? 23'b00000000000000000000000: a;    


 
endmodule



module powertwo (s3, e3, m3, s1, e1, m1);

output s3;
output [7:0] e3;
output [22:0] m3;
input s1;
input [7:0] e1;
input [22:0] m1;

wire [7:0] mbuff, exp;
wire [23:0] mag;
                                 
assign exp = ( e1 - 8'b01111111 );
assign mag = {8'b00000001 , m1};

assign mbuff =(s1==0)? ((exp == 8'b00000111) ? mag[23:16]:
                        (exp == 8'b00000110) ? mag[24:17]:
                        (exp == 8'b00000101) ? mag[25:18]:
                        (exp == 8'b00000100) ? mag[26:19]:
                        (exp == 8'b00000011) ? mag[27:20]:
                        (exp == 8'b00000010) ? mag[28:21]: 
                        (exp == 8'b00000001) ? mag[29:22]: mag[30:23]):
                        ((exp == 8'b00000111) ? mag[23:16]:
                        (exp == 8'b00000110) ? (8'b00000000 - mag[24:17]):
                        (exp == 8'b00000101) ? (8'b00000000 - mag[25:18]):
                        (exp == 8'b00000100) ? (8'b00000000 - mag[26:19]):
                        (exp == 8'b00000011) ? (8'b00000000 - mag[27:20]):
                        (exp == 8'b00000010) ? (8'b00000000 - mag[28:21]):
                        (exp == 8'b00000001) ? (8'b00000000 - mag[29:22]):
                               (8'b00000000 - mag[30:23]));          

assign s3 = 1'b0;
assign e3 =(e1 == 8'b00000000) ? 8'b01111111 : mbuff + 8'b01111111;
assign m3 = 23'b00000000000000000000000; 
                
endmodule                                                            












module get_j (j, s1, e1, m1);

output [4:0]  j;
input s1;
input [7:0] e1;
input [22:0] m1;


wire [7:0] exp;
wire [27:0] mag;
                  
assign exp = ( e1 - 8'b01111111 );               
assign mag = {5'b00001 , m1};

assign j = (exp == 8'b00000100) ? mag[23:19]:
           (exp == 8'b00000011) ? mag[24:20]:
           (exp == 8'b00000010) ? mag[25:21]: 
           (exp == 8'b00000001) ? mag[26:22]:
           (exp == 8'b00000000) ? mag[27:23]: 5'b00000;

endmodule

module divide(s2, e2, m2, s1, e1, m1);

output s2;
output [7:0] e2;
output [22:0] m2;
input s1; 
input [7:0] e1; 
input [22:0] m1;


assign s2=s1;

assign  e2= ( e1 > 8'b10000011) ?  ( e1 - 8'b00000101 )  : 8'b00000000;

assign m2 = m1;

endmodule



module program (outs ,oute ,outm ,xs ,xe ,xm );

output outs;
output [7:0] oute;
output [22:0] outm;
input xs;
input [7:0] xe;
input [22:0] xm;

wire lows,highs,ones,invs,ns,twoe9s,n1s,n2s,n2as,r1s,r1as,r1bs,r2s,l1s,l2s;
wire a1s,a2s,ms,qs,ss,ps,rs,sleads,strails,e1s,nums;
wire stemp19,stemp20,stemp21;
wire stemp,stemp1,stemp2,stemp3,stemp4,stemp5,stemp6,stemp7,stemp8,stemp9;
wire stemp10,stemp11,stemp12,stemp13,stemp14,stemp15,stemp16,stemp17,stemp18;
wire [2:0] flag, flag2,flag3;
wire [4:0] j;
wire [7:0] lowe,highe,onee,inve,ne,twoe9e,n1e,n2e,n2ae,r1e,r1ae,r1be,r2e,l1e,l2e;
wire [7:0] a1e,a2e,me,qe,se,pe,re,sleade,straile,e1e,nume,etemp19;
wire [7:0] etemp,etemp1,etemp2,etemp3,etemp4,etemp5,etemp6,etemp7,etemp8,etemp9; 
wire [7:0] etemp10,etemp11,etemp12,etemp13,etemp14,etemp15,etemp16,etemp17,etemp18;
wire [22:0] lowm,highm,onem,invm,nm,twoe9m,n1m,n2m,n2am,r1m,r1am,r1bm,r2m,l1m,l2m;
wire [22:0] a1m,a2m,mm,qm,sm,pm,rm,sleadm,strailm,e1m,numm,mtemp19;
wire [22:0] mtemp,mtemp1,mtemp2,mtemp3,mtemp4,mtemp5,mtemp6,mtemp7,mtemp8,mtemp9; 
wire [22:0] mtemp10,mtemp11,mtemp12,mtemp13,mtemp14,mtemp15,mtemp16,mtemp17,mtemp18;

assign ones= 1'b0;
assign onee= 8'b01111111;
assign onem= 23'b00000000000000000000000;

assign lows= 1'b0;
assign lowe= 8'b01100110;
assign lowm= 23'b00000000000000000000000;

assign highs= 1'b0;
assign highe= 8'b10000110;
assign highm= 23'b10111000110101110111010;

assign nums=1'b0;
assign nume=8'b10000100;
assign numm=23'b00000000000000000000000;

assign invs=1'b0;
assign inve=8'b10000100;
assign invm=23'b01110001010101000111011;

assign twoe9s=1'b0;
assign twoe9e=8'b10001000;
assign twoe9m=23'b00000000000000000000000;

assign l1s=1'b0;
assign l1e=8'b01111001;
assign l1m=23'b01100010111001000000000;

assign l2s=1'b0;
assign l2e=8'b01100110;
assign l2m=23'b01111111011111010001110;

assign a1s=1'b0;
assign a1e=8'b01111110;
assign a1m=23'b01010101010101011101100;


multiplication mul1(stemp,etemp,mtemp,invs,xs,inve,xe,invm,xm);
round rou1(ns,ne,nm,stemp,etemp,mtemp);
modulo32 mod1(stemp1,etemp1,mtemp1,ns,ne,nm);

 
addition add1(n2as,n2ae,n2am,nums,stemp1,nume,etemp1,numm,mtemp1);
assign n2s= (ns==1'b1) ? n2as : stemp1;
assign n2e= (ns==1'b1) ? n2ae : etemp1;
assign n2m= (ns==1'b1) ? n2am : mtemp1;


assign stemp2= ~n2s;
addition add2(n1s,n1e,n1m,ns,stemp2,ne,n2e,nm,n2m);
assign stemp21= 1'b0;
compare comp1(flag2,stemp21,twoe9s,ne,twoe9e,nm,twoe9m);

multiplication mul2(stemp3,etemp3,mtemp3,ns,l1s,ne,l1e,nm,l1m);
assign stemp4= ~stemp3;
addition add3(r1as,r1ae,r1am,stemp4,xs,etemp3,xe,mtemp3,xm);

multiplication mul3(stemp5,etemp5,mtemp5,n1s,l1s,n1e,l1e,n1m,l1m);
assign stemp6= ~stemp5;
addition add4(stemp7,etemp7,mtemp7,stemp6,xs,etemp5,xe,mtemp5,xm);
assign stemp8= ~n2s;
addition add5(stemp9,etemp9,mtemp9,stemp8,stemp7,n2e,etemp7,n2m,mtemp7);
multiplication mul4(r1bs,r1be,r1bm,stemp9,l1s,etemp9,l1e,mtemp9,l1m);
assign r1s= (flag2 == 3'b001) ? r1as : r1bs;
assign r1e= (flag2 == 3'b001) ? r1ae : r1be;
assign r1m= (flag2 == 3'b001) ? r1am : r1bm;

assign stemp10= ~ns;
multiplication mul5(r2s,r2e,r2m,stemp10,l2s,ne,l2e,nm,l2m);
divide d1(ms,me,mm,n1s,n1e,n1m);
addition add6(rs,re,rm,r1s,r2s,r1e,r2e,r1m,r2m);
multiplication mul6(stemp11,etemp11,mtemp11,rs,a2s,re,a2e,rm,a2m);
addition add7(stemp12,etemp12,mtemp12,stemp11,a1s,etemp11,a1e,mtemp11,a1m);
multiplication mul7(stemp13,etemp13,mtemp13,rs,rs,re,re,rm,rm);
multiplication  mul8(qs,qe,qm,stemp13,stemp12,etemp13,etemp12,mtemp13,mtemp12);
addition add8(stemp14,etemp14,mtemp14,r2s,qs,r2e,qe,r2m,qm);
addition add9(ps,pe,pm,stemp14,r1s,etemp14,r1e,mtemp14,r1m);
get_j get1(j,n2s,n2e,n2m);



assign sleads = 1'b0;
assign strails = 1'b0;

assign sleade = 8'b01111111;
 
assign straile= (j == 5'b00000) ?  8'b00000000:
		(j == 5'b00001) ?  8'b01101010:
		(j == 5'b00010) ?  8'b01101001:
		(j == 5'b00011) ? 8'b01101011:
		(j == 5'b00100) ? 8'b01101000:
		(j == 5'b00101) ? 8'b01101101:
                (j == 5'b00110) ? 8'b01101100:
                (j == 5'b00111) ? 8'b01101101:
                (j == 5'b01000) ? 8'b01101101:
                (j == 5'b01001) ? 8'b01101101:
		(j == 5'b01010) ? 8'b01101101:
                (j == 5'b01011) ? 8'b01101001:
                (j == 5'b01100) ? 8'b01101100:
                (j == 5'b01101) ? 8'b01101100:
                (j == 5'b01110) ? 8'b01101101:
                (j == 5'b01111) ? 8'b01101101:
                (j == 5'b10000) ? 8'b01101101:
                (j == 5'b10001) ? 8'b01101101:
                (j == 5'b10010) ? 8'b01101101:
                (j == 5'b10011) ? 8'b01101011:
                (j == 5'b10100) ? 8'b01101101:
                (j == 5'b10101) ? 8'b01101101:
                (j == 5'b10110) ? 8'b01101011:
                (j == 5'b10111) ? 8'b01101100:
                (j == 5'b11000) ? 8'b01101101:
                (j == 5'b11001) ? 8'b01101101:
                (j == 5'b11010) ? 8'b01101100:
                (j == 5'b11011) ? 8'b01101010:
                (j == 5'b11100) ? 8'b01101010:
                (j == 5'b11101) ? 8'b01101101:
                (j == 5'b11110) ? 8'b01101101: 8'b01101101;

assign sleadm = (j == 5'b00000) ? 23'b00000000000000000000000:
                (j == 5'b00001) ? 23'b00000101100110110000000:
                (j == 5'b00010) ? 23'b00001011010101011000000:
                (j == 5'b00011) ? 23'b00010001001100000000000:
                (j == 5'b00100) ? 23'b00010111001010111000000:
                (j == 5'b00101) ? 23'b00011101010010000000000:
                (j == 5'b00110) ? 23'b00100011100001111000000:
                (j == 5'b00111) ? 23'b00101001111010011000000:
                (j == 5'b01000) ? 23'b00110000011011111000000:
                (j == 5'b01001) ? 23'b00110111000110100000000:
                (j == 5'b01010) ? 23'b00111101111010100000000:
                (j == 5'b01011) ? 23'b01000100111000001000000:
                (j == 5'b01100) ? 23'b01001011111111011000000:
                (j == 5'b01101) ? 23'b01010011010000101000000:
                (j == 5'b01110) ? 23'b01011010101100000000000:
                (j == 5'b01111) ? 23'b01100010010001111000000:
                (j == 5'b10000) ? 23'b01101010000010011000000:
                (j == 5'b10001) ? 23'b01110001111101110000000:
                (j == 5'b10010) ? 23'b01111010000100010000000:  
		(j == 5'b10011) ? 23'b10000010010110001000000:
                (j == 5'b10100) ? 23'b10001010110011100000000:
                (j == 5'b10101) ? 23'b10010011011100110000000:
                (j == 5'b10110) ? 23'b10011100010010010000000:
                (j == 5'b10111) ? 23'b10100101010100000000000:
                (j == 5'b11000) ? 23'b10101110100010011000000:
                (j == 5'b11001) ? 23'b10110111111101110000000:
                (j == 5'b11010) ? 23'b11000001100110011000000:
                (j == 5'b11011) ? 23'b11001011011100100000000:
                (j == 5'b11100) ? 23'b11010101100000011000000: 
		(j == 5'b11101) ? 23'b11011111110010010000000:
                (j == 5'b11110) ? 23'b11101010010010101000000:
                                  23'b11110101000001110000000;

assign strailm= (j == 5'b00000) ? 23'b00000000000000000000000:
                (j == 5'b00001) ? 23'b10100110001010110000101:
                (j == 5'b00010) ? 23'b10110011111001100010010:
                (j == 5'b00011) ? 23'b11010000000100100101110:
                (j == 5'b00100) ? 23'b11100011111010101000110:
                (j == 5'b00101) ? 23'b11001100010110100010111:
                (j == 5'b00110) ? 23'b00110111001110101011001:
                (j == 5'b00111) ? 23'b01111101010001111111100:
                (j == 5'b01000) ? 23'b10000010100011000110111:
                (j == 5'b01001) ? 23'b11001101110011101010101:
                (j == 5'b01010) ? 23'b10010011000001001000111:
                (j == 5'b01011) ? 23'b10000001100001100010010:
                (j == 5'b01100) ? 23'b01101010100110110001011:
                (j == 5'b01101) ? 23'b10101011010011101010100:
                (j == 5'b01110) ? 23'b11110111010100100001011:
                (j == 5'b01111) ? 23'b10101100000011101001011:
                (j == 5'b10000) ? 23'b10011001100111111100111:
                (j == 5'b10001) ? 23'b01111010001110110001100:
                (j == 5'b10010) ? 23'b00011100111110101100000:
                (j == 5'b10011) ? 23'b10011001010011001100111:
                (j == 5'b10100) ? 23'b01010000100010101010100:
                (j == 5'b10101) ? 23'b11101100001100110111001:
                (j == 5'b10110) ? 23'b10000010101000111111000:
                (j == 5'b10111) ? 23'b11011001000111110001001:
                (j == 5'b11000) ? 23'b11100110010101101011010:
                (j == 5'b11001) ? 23'b10111100101111101101100:
                (j == 5'b11010) ? 23'b11101110110000101010101:   
		(j == 5'b11011) ? 23'b10111001110111110010000:
                (j == 5'b11100) ? 23'b10111001111101110100101:
                (j == 5'b11101) ? 23'b11001100110111101110011:
                (j == 5'b11110) ? 23'b11101000101010010010010:
                                  23'b10010110110110111001001;     



addition add10(ss,se,sm,sleads,strails,sleade,straile,sleadm,strailm);
multiplication mul9(stemp15,etemp15,mtemp15,ss,ps,se,pe,sm,pm);
addition add11(stemp16,etemp16,mtemp16,stemp15,strails,etemp15,straile,mtemp15,strailm);
addition add12(e1s,e1e,e1m,sleads,stemp16,sleade,etemp16,sleadm,mtemp16);
powertwo p1(stemp17,etemp17,mtemp17,ms,me,mm);
multiplication mul10(stemp18,etemp18,mtemp18,stemp17,e1s,etemp17,e1e,mtemp17,e1m);
/*
assign stemp20= 1'b0;

compare comp2(flag,stemp20,highs,xe,highe,xm,highm);
compare comp3(flag3,stemp20,lows,xe,lowe,xm,lowm);
addition add13(stemp19,etemp19,mtemp19,ones,xs,onee,xe,onem,xm);

assign outs=(xe == 8'b11111111) ?
            ((xm == 23'b00000000000000000000000)? ((xs==1'b0)? 1'b0:1'b0):
             "x"):(flag == 3'b001) ?  stemp19 :
                   (flag3 == 3'b100) ? 1'b0 : stemp18;

assign oute=(xe == 8'b11111111) ?
            ((xm == 23'b00000000000000000000000)? ((xs==1'b0)? 8'b11111111:8'b00000000):
             "xxxxxxxx"):(flag == 3'b001) ?  etemp19 :
                   (flag3 == 3'b100) ? 8'b11111111 : etemp18;  

assign outm=(xe == 8'b11111111) ?
            ((xm == 23'b00000000000000000000000)? ((xs==1'b0)? 23'b00000000000000000000000:23'b00000000000000000000000):
             "xxxxxxxxxxxxxxxxxxxxxxx"):(flag == 3'b001) ?  mtemp19 :
                   (flag3 == 3'b100) ? 23'b00000000000000000000000:mtemp18;  

*/
assign outs= stemp18;
assign oute= etemp18;
assign outm= mtemp18;


endmodule


module test_exp();

reg [31:0] x;
wire [31:0] y;

wire xs;
wire [7:0] xe;
wire [22:0] xm;

wire ys;
wire [7:0] ye;
wire [22:0] ym;

assign xs = x[31];
assign xe = x[30:23];
assign xm = x[22:0];

assign ys = y[31];
assign ye = y[30:23];
assign ym = y[22:0];

program p(y[31],y[30:23],y[22:0],x[31],x[30:23],x[22:0]);

initial begin
	$dumpfile("exp.vcd");
	$dumpvars(0, test_exp);
	x = 32'h40000000;
	#50000;
	$display("%H", y);
end

endmodule
