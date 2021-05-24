---
title: Test Signal Generator
subtitle: VLSI-Design Module - Presentation
author: L Hillinger, D Cunningham, R Dillon
date: SS2021
---

Overview
========

* Features
* Interface Signals
* Block Diagram
* Functional Description
* Simulation Result
* Device Utilization and Performance
* Demonstration
* Questions

Features
========

  * Models QRS-Complex and T-Wave
  * Average time values based on 72 bpm
  * Enable input for external prescaler

Interface Signals
=================

![Heartbeat Generator - Schematic Symbol](images/heartbeat_gen_symbol.pdf){width=40%}


Functional Description
======================

Simplification to Digital Pulses
---------

![Electrocardiogram](images/ECG-SinusRhythmLabel.png){width=20%}


![QRS Complex and T Wave Pulses](images/qrs-complex-t-wave-pulses.pdf){width=80%}


Functional Description
======================

Conceptional RTL Diagram
---------------

![Heartbeat Generator - Conceptional RTL](images/heartbeat_gen_conceptional_rtl.pdf){width=60%}

Simulation Result - Top Level
=============================

![Two Periods - Simulation Result](images/heartbeat_gen_two_periods_simwave.png){width=80%}

Device Utilization and Performance
==================================

```pure
+------------------------------------------------------------------------------+
; Fitter Summary                                                               ;
+------------------------------------+-----------------------------------------+
; Fitter Status                      ; Successful - Wed Mar 31 11:50:15 2021   ;
; Quartus II 32-bit Version          ; 13.0.1 Build 232 06/12/2013 SP 1 SJ Web ;
; Revision Name                      ; de1_heartbeat_gen                       ;
; Top-level Entity Name              ; de1_heartbeat_gen                       ;
; Family                             ; Cyclone II                              ;
; Device                             ; EP2C20F484C7                            ;
; Timing Models                      ; Final                                   ;
; Total logic elements               ; 50 / 18,752 ( < 1 % )                   ;
;     Total combinational functions  ; 50 / 18,752 ( < 1 % )                   ;
;     Dedicated logic registers      ; 26 / 18,752 ( < 1 % )                   ;
; Total registers                    ; 26                                      ;
; Total pins                         ; 15 / 315 ( 5 % )                        ;
; Total virtual pins                 ; 0                                       ;
; Total memory bits                  ; 0 / 239,616 ( 0 % )                     ;
; Embedded Multiplier 9-bit elements ; 0 / 52 ( 0 % )                          ;
; Total PLLs                         ; 0 / 4 ( 0 % )                           ;
+------------------------------------+-----------------------------------------+
```

Demonstration
=============

Prototype Setup
---------------

![Test Environment on DE1 Prototype Board](images/de1_heartbeat_gen_schematic.pdf){width=70%}

Demonstration
=============

Test Environment
----------------





Questions
=========

Thank you for your attention !

