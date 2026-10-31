clear
clc

PORT = "COM3";
BAUD = 9600;

s = serialport(PORT, BAUD);
pause(2);

disp("Comunicacion bidireccional iniciada");
disp("La FPGA regresara el byte recibido mas 1");

while true
    valor = input('Ingrese un numero entre 0 y 255: ');

    if valor < 0 || valor > 255
        disp('Valor fuera de rango');
        continue;
    end

    write(s, uint8(valor), "uint8");
    disp(['Enviado: ', num2str(valor)]);

    pause(0.1);

    if s.NumBytesAvailable > 0
        respuesta = read(s, 1, "uint8");
        disp(['Respuesta de FPGA: ', num2str(double(respuesta))]);
    else
        disp('No se recibio respuesta');
    end
end
