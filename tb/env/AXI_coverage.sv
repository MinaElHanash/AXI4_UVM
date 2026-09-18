package AXI_coverage_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import AXI_transaction_pkg::*;

    class AXI_coverage extends uvm_component;
        `uvm_component_utils(AXI_coverage)

        uvm_analysis_imp #(AXI_transaction, AXI_coverage) ap_imp;

        AXI_transaction cov_txn;

        covergroup cg_axi_protocol;
            option.name         = "AXI_Protocol_Coverage";
            option.per_instance = 1;

            cp_awaddr: coverpoint cov_txn.AWADDR {
                bins lower_bound        = {16'd0};
                bins upper_bound        = {16'd4092};
                bins normal_range[16]   = {[16'd4 : 16'd4088]};
                bins out_of_range       = {[16'd4096 : $]};
            }

            cp_araddr: coverpoint cov_txn.ARADDR {
                bins lower_bound        = {16'd0};
                bins upper_bound        = {16'd4092};
                bins normal_range[16]   = {[16'd4 : 16'd4088]};
                bins out_of_range       = {[16'd4096 : $]};
            }

            cp_awlen: coverpoint cov_txn.AWLEN {
                bins len_vals[16]       = {[0 : 255]};
            }

            cp_arlen: coverpoint cov_txn.ARLEN {
                bins len_vals[16]       = {[0 : 255]};
            }

            cp_write_boundary: coverpoint (cov_txn.AWADDR + ((cov_txn.AWLEN + 1) * 4)) {
                bins safe_transfer[16]  = {[0 : 4092]};
                bins perfect_4kb        = {4096};
                bins illegal_cross      = {[4097 : $]};
            }

            cp_read_boundary: coverpoint (cov_txn.ARADDR + ((cov_txn.ARLEN + 1) * 4)) {
                bins safe_transfer[16]  = {[0 : 4092]};
                bins perfect_4kb        = {4096};
                bins illegal_cross      = {[4097 : $]};
            }

            cp_bresp_trans: coverpoint cov_txn.BRESP {
                bins okay          = {2'b00};
                bins slverr        = {2'b10};
                bins okay_okay     = (2'b00 => 2'b00);
                bins okay_slverr   = (2'b00 => 2'b10);
                bins slverr_okay   = (2'b10 => 2'b00);
                bins slverr_slverr = (2'b10 => 2'b10);
            }

            cp_rresp_trans: coverpoint cov_txn.RRESP {
                bins okay          = {2'b00};
                bins slverr        = {2'b10};
                bins okay_okay     = (2'b00 => 2'b00);
                bins okay_slverr   = (2'b00 => 2'b10);
                bins slverr_okay   = (2'b10 => 2'b00);
                bins slverr_slverr = (2'b10 => 2'b10);
            }

            cross_awaddr_awlen: cross cp_awaddr, cp_awlen {
                // Ignore base addresses that are explicitly out of range
                ignore_bins ignore_out = binsof(cp_awaddr.out_of_range);
                
                // Ignore combinations where address + burst size exceeds the 4KB (4096) limit
                ignore_bins ignore_4kb_cross = cross_awaddr_awlen with 
                                               (cp_awaddr + ((cp_awlen + 1) * 4) > 4096);
            }

            cross_araddr_arlen: cross cp_araddr, cp_arlen {
                // Ignore base addresses that are explicitly out of range
                ignore_bins ignore_out = binsof(cp_araddr.out_of_range);
                
                // Ignore combinations where address + burst size exceeds the 4KB (4096) limit
                ignore_bins ignore_4kb_cross = cross_araddr_arlen with 
                                               (cp_araddr + ((cp_arlen + 1) * 4) > 4096);
            }
        endgroup

        function new(string name = "AXI_coverage", uvm_component parent);
            super.new(name, parent);
            cg_axi_protocol = new();
        endfunction 

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            ap_imp = new("ap_imp", this);
        endfunction

        virtual function void write(AXI_transaction t);
            this.cov_txn = t;
            cg_axi_protocol.sample();
        endfunction

    endclass 
    
endpackage