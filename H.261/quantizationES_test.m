%   lang: ES
%
%	Función:
%		- Mostrar por pantalla:
%			* Porcentaje de coeficientes nulos
%			* RMS del error de cuantificación
%		- Represetar:
%			* Imagen descuantificada
%			* Imagen de error de cuantificación
%   Parámetros a modificar:
%   	'file' : Ruta del archivo de imagen
%   	't' : Umbral de cuantificación
%   	'q' : Escalón de cuantificación
%	Dependencias:
%		quantizationES.m

file = '';
t = 0;
q = 2;

%   Elapsed time
tic;
warning('off', 'Images:initSize:adjustingMag');

%	Cuantificación
[ RMS, ceros_porcentaje, Imagen_Recuperada, Imagen_Error ] = quantizationES(file, t, q);

%   Results
fprintf('Datos estadísticos:\n');
fprintf('\tValor RMS:\t\t\t\t\t\t%f\n', RMS);
fprintf('\tCoeficientes nulos:\t\t\t\t%f%%\n', ceros_porcentaje);

%   Elapsed time
fprintf('\n');
toc;

%   Muestra imagen reconstruida
figure(1);
imshow(Imagen_Recuperada);
title('Imagen reconstruida');
figure(2);
imshow(Imagen_Error);
title('Imagen error');