%   lang: ES
%
%	Función:
%		- Test de calidad para todos los posibles factores de escala (2, 4, ..., 62)
%			* RMS del error
%			* Porcentaje de coeficientes nulos
%		- Represeta:
%			* Gráfica del RMS del error
%			* Gráfica del porcentaje de coeficientes nulos
%   Parámetros a modificar:
%   	'file' : Ruta del archivo de imagen
%	Dependencias:
%		quantizationES.m

file = 'test.png';

%   Elapsed time
tic;

%   Inicialización de variables
escalas = zeros(1, 32);
RMSs = zeros(1, 32);
porcentajes = zeros(1, 32);

%   Cuantifica para todos los factores de escala posibles
for i = 2:2:62
    fprintf('Test %d de %d (%f%% completado)\n', i/2, 31, round(10000 * i / 62) / 100);
    escalas(i/2 + 1) = i;
    [RMSs(i/2 + 1) porcentajes(i/2 + 1)] = quantizationES(file, i);
end

%   Valor inicial
escalas(1) = 0;
RMSs(1) = 0;
porcentajes(1) = 0;

%   Elapsed time
toc;

%   Representa los resultados
figure(1);
plot(escalas, RMSs);
xlabel('Factor de escala');
ylabel('RMS del error');
grid;
figure(2);
plot(escalas, porcentajes);
xlabel('Factor de escala');
ylabel('Coeficientes nulos (%)');
grid;