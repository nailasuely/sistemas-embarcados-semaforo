
<h1 align="center">
  <br>
    <img width="300px" src="">
  <br>
  Semáforo Inteligente
  <br>
</h1>
<div align="center">

<h4 align="center">Projeto da disciplina TEC470 - Sistemas Embarcado </h4>

<p align="center">
<div align="center">

[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](hhttps://github.com/nailasuely/sistemas-embarcados-semaforo/blob/main/LICENSE)

> Este projeto implementa um sistema de **controle de semáforo inteligente** utilizando um microcontrolador **8051**, com **contagem de veículos**, **modo de emergência** e **display de 7 segmentos** para exibição de tempo restante.

## Download do repositório

<p align="center">
  
```
gh repo clone nailasuely/sistemas-embarcados-semaforo
```
</p>

</div>
</div>

<details open="open">
<summary>Sumário</summary>
  
- [🔧 Componentes Utilizados](#-componentes-utilizados)
- [🎥 Vídeo de Demonstração](#-vídeo-de-demonstração)
- [👩‍💻 Autoras](#-autora)
- [📚 Referências](#-referências)


![---](https://github.com/nailasuely/task05-clock/blob/main/src/prancheta.png)

## ✨ Funcionalidades

- 🟢 Controle completo do ciclo de semáforo (verde, amarelo, vermelho)
- 🚗 Contagem de veículos utilizando sensor (simulado por botão)
- ⚠️ Detecção de congestionamento (6 ou mais veículos)
- 🚨 Modo de emergência com prioridade imediata
- 🧮 Exibição do tempo restante em display de 7 segmentos (4 dígitos)
- 💡 Sinais visuais por LEDs indicando situação de tráfego e emergência

![---](https://github.com/nailasuely/task05-clock/blob/main/src/prancheta.png)

## ⚙️ Hardware Simulado

| Componente         | Porta  | Pino       | Descrição                          |
|--------------------|--------|------------|------------------------------------|
| Luz Verde          | P1     | P1.0       | Ativada durante o tempo verde      |
| Luz Amarela        | P1     | P1.1       | Ativada durante a transição        |
| Luz Vermelha       | P1     | P1.2       | Ativada durante o tempo vermelho   |
| LED Emergência     | P1     | P1.3       | Indicador de modo emergência       |
| LED Tráfego        | P1     | P1.4       | Indicador de tráfego intenso       |
| Sensor de Veículos | P3     | P3.2       | Interrupção externa (INT0)         |
| Botão Emergência   | P3     | P3.3       | Interrupção externa (INT1)         |
| Display de Segmentos | P0   | -          | Segmentos (a-g) dos dígitos        |
| Seleção de Dígitos | P2     | -          | Multiplexação dos 4 dígitos        |

![---](https://github.com/nailasuely/task05-clock/blob/main/src/prancheta.png)


## 🙋‍♀️ Autoras

[//]: contributor-faces

<a href="https://github.com/nailasuely"><img src="https://avatars.githubusercontent.com/u/98486996?v=4" title="naila" width="100"></a>
<a href="https://github.com/yasmincsme"><img src="https://avatars.githubusercontent.com/u/67525293?v=4" title="yas" width="100" ></a>

[//]: contributor-faces

![---](https://github.com/nailasuely/task05-clock/blob/main/src/prancheta.png)

