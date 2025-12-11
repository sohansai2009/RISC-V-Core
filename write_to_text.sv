module reg_file_capture(write_perm,regfile);
input logic write_perm; //from if module
input logic [31:0] regfile [31:0];

always_comb begin
if(write_perm==1)
begin
write_to_file("dut_reg_data.txt");
end
end

//task
task write_to_file(string filename);
integer file;
int i;
begin
file=$fopen(filename,"w");
for(i=0;i<32;i++)
begin
$fwrite(file,"x%02d:%h",i,regfile[i]);
$display("Reg number :%0d, data:%h",i,regfile[i]);
end
end
endtask
endmodule

