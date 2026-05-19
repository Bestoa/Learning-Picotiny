/*
This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.
*/
OUTPUT_FORMAT("elf32-littleriscv", "elf32-littleriscv", "elf32-littleriscv")
OUTPUT_ARCH(riscv)
ENTRY(crtStart)

MEMORY
{
  FLASH (rx)      : ORIGIN = 0x00000000, LENGTH = 1024
}

SECTIONS {
  .text :
  {
    *(.text)           /* .text sections (code) */
    . = ALIGN(256);
  } > FLASH
}
