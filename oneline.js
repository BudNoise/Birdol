function level1() {
  __STD_PRINT_LOG__(1);
  function level2() {
    __STD_PRINT_LOG__(2);
    function level3() {
      __STD_PRINT_LOG__(3);
      function level4() {
        __STD_PRINT_LOG__(4);
        function level5() {
          __STD_PRINT_LOG__(5);
        }
        level5();
      }
      level4();
    }
    level3();
  }
  level2();
}

level1();
