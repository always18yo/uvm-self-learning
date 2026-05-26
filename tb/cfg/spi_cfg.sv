//***************************************************************************************************************
// Author: Van Le
// vanleatwork@yahoo.com
// Phone: VN: 0396221156, US: 5125841843
//***************************************************************************************************************
class spi_cfg extends uvm_object;

  `uvm_object_utils(spi_cfg)
  
  //
  // NEW
  //
  rand bit         ass;
  rand bit         ie;
  rand bit         lsb;
  rand bit         txneg;
  rand bit         rxneg;
  rand bit [6:0]   char_len;
  
  bit [127:0] mask;
  
  function new(string name = "");
    super.new(name);
  endfunction

  constraint default_contraint {
    ass == 1;
    ie  == 1;
    lsb == 0;
    txneg == 1;
    rxneg == 0;
    char_len inside {[10:100]};
  }

  function void set_mask();
  if (char_len == 0)
    mask = 128'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF;
  else
    mask = (128'h1 << char_len) - 1;
  endfunction

endclass
