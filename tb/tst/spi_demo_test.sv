//***************************************************************************************************************
// Author: Van Le
// vanleatwork@yahoo.com
// Phone: VN: 0396221156, US: 5125841843
//***************************************************************************************************************
class spi_demo_test extends uvm_test;

  `uvm_component_utils(spi_demo_test)

  spi_env       #(spi_tlm, spi_tlm)  m_env;
  spi_cfg                            spi_cfg_h;
  apb_demo_seq #(spi_tlm, spi_tlm)   apb_seq;

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    m_env     = spi_env      #(spi_tlm,spi_tlm)::type_id::create("m_env", this);
    spi_cfg_h = spi_cfg                          ::type_id::create("spi_cfg_h");
    uvm_config_db#(spi_cfg)::set(this,"*","spi_cfg",spi_cfg_h);

    apb_seq   = apb_demo_seq #(spi_tlm,spi_tlm)::type_id::create("apb_seq");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this,"spi_demo_test");

    apb_seq.start(m_env.apb_agt.sequencer);

    phase.drop_objection(this,"spi_demo_test");
  endtask

endclass

   
