%   lang: ES
%
%	Función:
%		- Mostrar por pantalla:
%			* Número de bloques con predicción vertical
%			* Número de bloques con predicción horizontal
%			* Número de bloques con predicción DC
%			* Número de bloques sin predicción
%			* RMS del error de predicción
%		- Represetar:
%			* Imagen predicción
%			* Imagen de error de predicción
%   Parámetros a modificar:
%   	'file' : Ruta del archivo de imagen
%		'modo' : Modo a aplicar (ver documentación de las dependencias)
%	Dependencias:
%		predictIntraES.m

%   Archivo de imagen
file = 'test.png';
modo = 'todos';

%   Elapsed time
tic;
warning('off', 'Images:initSize:adjustingMag');

%   Predicción intra según H.214 para el modo elegido
[Prediccion, Error, RMS, total_bloques, verticales, horizontales, dc, sin] = predictIntraES(file, modo);

%   Results
fprintf('\tBloques con predicción vertical:\t\t%d/%d (%f%%)\n', verticales, total_bloques, round(verticales/total_bloques * 10000) / 100);
fprintf('\tBloques con predicción horizontal:\t\t%d/%d (%f%%)\n', horizontales, total_bloques, round(horizontales/total_bloques * 10000) / 100);
fprintf('\tBloques con predicción DC:\t\t\t\t%d/%d (%f%%)\n', dc, total_bloques, round(dc/total_bloques * 10000) / 100);
fprintf('\tBloques sin predicción:\t\t\t\t\t%d/%d (%f%%)\n', sin, total_bloques, round(sin/total_bloques * 10000) / 100);
fprintf('\n');
fprintf('RMS del error de predicción:\t\t\t\t\t\t\t%f\n', RMS);

%   Elapsed time
fprintf('\n');
toc;

%   Figures
figure(1);
imshow(Prediccion)
title('Imagen predicción');
figure(2);
imshow(Error)
title('Imagen de error de predicción');

fprintf('\n')