`timescale 1ns/1ps
import anoc_rv_pkg::*;

module tb_pkg;

    flit_t flit;

    initial begin
        $display("FLIT WIDTH     = %0d", FLIT_WIDTH);
        $display("HEADER WIDTH   = %0d", HEADER_WIDTH);
        $display("PAYLOAD WIDTH  = %0d", PAYLOAD_WIDTH);
        $display("STRUCT SIZE    = %0d", $bits(flit));

        if ($bits(flit) != FLIT_WIDTH)
            $fatal("Package Width Error");

        $display("PACKAGE PASS");
        $finish;
    end

endmodule
