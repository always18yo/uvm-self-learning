//***************************************************************************************************************
// Author: Van Le
// vanleatwork@yahoo.com
// Phone: VN: 0396221156, US: 5125841843
//***************************************************************************************************************

//============================================================================================================================
// Scoreboard responsible for data checking
//============================================================================================================================
class sb #(type REQ = uvm_sequence_item) extends uvm_scoreboard;

  `uvm_component_param_utils(sb #(REQ))
  uvm_tlm_analysis_fifo #(REQ) ref_ap_fifo; // reference data 
  uvm_tlm_analysis_fifo #(REQ) act_ap_fifo; // actual data 
  string  my_name;

  // X Todo: declare a uart_cfg handle named cfg
  uart_cfg cfg;  
  //
  // NEW
  //
  function new(string name, uvm_component parent);
    super.new(name,parent);
    my_name = name;
  endfunction
		
  //
  // BUILD phase
  //
  function void build_phase(uvm_phase phase);
    // P2 Todo: instantiate ref_ap_fifo
    // P2 Todo: instantiate act_ap_fifo
    super.build_phase(phase);
    ref_ap_fifo = new("ref_ap_fifo", this);
    act_ap_fifo = new("act_ap_fifo", this);
  endfunction

  //
  // CONNECT phase
  //
  function void connect_phase(uvm_phase phase); 
    super.connect_phase(phase);	  
    // X Todo: use uvm_config_db::get to obtain the handle to uart_cfg
    if (!uvm_config_db #(uart_cfg)::get(this, "", "cfg", cfg)) begin
      `uvm_error(my_name, "Could not retrieve uart_cfg")
    end
  endfunction

  //
  // CHECK phase
  //
  function void check_phase(uvm_phase phase);
    // At the end of simulation, if there are any packets left in the ref_ap_fifo, then
    // it is an error condition
    if (ref_ap_fifo.used() > 0) begin
      `uvm_error(my_name,$psprintf("ref_ap_fifo is not empty : %0d",ref_ap_fifo.used()))
    end
  endfunction

  //
  // RUN phase
  //
  task run_phase(uvm_phase phase);
     REQ ref_pkt;
     REQ act_pkt;

    forever begin
      // P2 Todo: get the next actual packet from the act_ap_fifo by calling get
      act_ap_fifo.get(act_pkt);
      // P2 Todo: verify that the ref_ap_fifo is not empty, otherwise issue an fatal error
      if (ref_ap_fifo.used() == 0) begin
	 `uvm_fatal(my_name, "ref_ap_fifo is empty")      
      end 	      

      // P2 Todo: get the next reference packet from the ref_ap_fifo by calling get
      // P2 Todo: perform comparison between the rx_data in the reference packet against the o_data in actual packet
      // P2 Todo: print match/mismatch message
      // X Todo: if inject_err==0, perform comparison as in the above two lines
      // X Todo: if inject_err==1, verify that the comparison fails as expected
      ref_ap_fifo.get(ref_pkt);

      if (cfg.inject_err == 0) begin
	 if (ref_pkt.rx_data == act_pkt.o_data) begin
            `uvm_info(my_name, $psprintf("MATCH: ref rx_data=%0h act o_data=%0h", ref_pkt.rx_data, act_pkt.o_data), UVM_NONE)		 
         end else begin
            `uvm_error(my_name, $psprintf("MISMATCH: ref rx_data=%0h act o_data=%0h", ref_pkt.rx_data, act_pkt.o_data)) 		 
         end
      end else begin
	  if (ref_pkt.rx_data != act_pkt.o_data) begin
	     `uvm_info(my_name, $psprintf("EXPECTED MISMATCH: ref rx_data=%0h act o_data=%0h", ref_pkt.rx_data, act_pkt.o_data), UVM_NONE)
          end else begin
	     `uvm_error(my_name, $psprintf("ERROR INJECTION FAILED: ref rx_data=%0h act o_data=%0h", ref_pkt.rx_data, act_pkt.o_data))	  
          end 		  
      end
    end
  endtask

endclass
