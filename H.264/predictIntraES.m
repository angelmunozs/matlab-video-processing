function [ Prediccion, Error, RMS, total_bloques, total_verticales, total_horizontales, total_dc, total_sin ] = predict( file, modo )
%   lang: ES
%
%   Función que realiza la predicción según el estándar H.264
%
%   Parámetros:
%       file: Nombre del archivo de imagen
%       modo: Modo de predicción que se utiliza. Opciones:
%           'vertical':     Modo 0 (vertical)
%           'horizontal':   Modo 1 horizontal)
%           'dc':           Modo 2 (DC)
%           'ninguno':      No se utiliza predicción
%           'todos':        Modo vertical, horizontal y DC
%   Devuelve:
%       Prediccion:             Imagen de predicción
%       Error:                  Imagen de error de predicción
%       RMS:                    RMS del error de predicción
%       total_bloques:          Número total de bloques analizados
%       total_verticales:       Número de bloques predichos según modo vertical
%       total_horizontales:     Número de bloques predichos según modo horizontal
%       total_dc:               Número de bloques predichos según modo dc
%       total_sin:              Número de bloques codificados sin predicción

    %   Control errores
    if(~strcmp(modo, 'vertical') && ~strcmp(modo, 'horizontal') && ~strcmp(modo, 'dc') && ~strcmp(modo, 'ninguno') && ~strcmp(modo, 'todos'))
        fprintf('Introduce un modo válido\n')
        fprintf('\tvertical:     Modo 0 (vertical)\n')
        fprintf('\thorizontal:   Modo 1 horizontal)\n')
        fprintf('\tdc:           Modo 2 (DC)\n')
        fprintf('\tninguno:      No se utiliza predicción\n')
        fprintf('\ttodos:        Modo vertical, horizontal y DC\n')       
        return;
    end

    %   Tamaño de los blolques
    M = 4;
    %   Almacena la imagen en tipo double
    Original = imread(file);
    %   Extrae la luminancia
    Luminancia = rgb2gray(Original);
    %   Convierte a tipo double y resta 128
    Convertida = double(Luminancia);
    %   Almacena el tamaño
    [alto, ancho] = size(Luminancia);
    %   Inicializa imagen final
    Prediccion = uint8(zeros(alto, ancho));
    %   Número de bloques analizados
    total_bloques = ceil(alto/M) * ceil(ancho/M);
    %   Inicializa número de bloques predichos
    total_verticales = 0;
    total_horizontales = 0;
    total_dc = 0;
    total_sin = 0;
    
    %   Si no se utiliza predicción
    if(strcmp(modo, 'ninguno'))
        Prediccion = Prediccion + 128;
        total_sin = total_bloques;
    else
        %   Recorre la imagen por bloques de 4x4
        for i = 1:M:alto
            for j = 1:M:ancho

                %   Bloque sin predicción
                Bloque = Convertida(i:i+M-1, j:j+M-1);
                %   Bloque predicción vertical
                Bloque_V = zeros(M);
                for m = 1:M
                    for n = 1:M
                        Bloque_V(m, n) = Bloque(n, 1);
                    end
                end
                %   Bloque predicción horizontal
                Bloque_H = zeros(M);
                for m = 1:M
                    for n = 1:M
                        Bloque_H(m, n) = Bloque(1, n);
                    end
                end
                %   Bloque predicción DC (media)
                media = mean(Bloque(:));
                Bloque_DC = zeros(M);
                for m = 1:M
                    for n = 1:M
                        Bloque_DC(m, n) = media;
                    end
                end

                %   En función del modo introducido
                if(strcmp(modo, 'dc'))
                    Prediccion(i:i+M-1, j:j+M-1) = uint8(Bloque_DC);
                    %   Incrementa en 1 el número de bloques predichos
                    total_dc = total_dc + 1;
                elseif(strcmp(modo, 'vertical'))
                    Prediccion(i:i+M-1, j:j+M-1) = uint8(Bloque_V);
                    %   Incrementa en 1 el número de bloques predichos
                    total_verticales = total_verticales + 1;
                elseif(strcmp(modo, 'horizontal'))
                    Prediccion(i:i+M-1, j:j+M-1) = uint8(Bloque_H);
                    %   Incrementa en 1 el número de bloques predichos
                    total_horizontales = total_horizontales + 1;
                else
                    %   Sum of Absolute Error
                    SAE_V = sum(sum(abs(Bloque - Bloque_V)));
                    SAE_H = sum(sum(abs(Bloque - Bloque_H)));
                    SAE_DC = sum(sum(abs(Bloque - Bloque_DC)));
                    %   Busca el mínimo y realiza la predicción según él
                    minimo = min([SAE_V, SAE_H, SAE_DC]);

                    switch minimo
                        case SAE_V
                            Prediccion(i:i+M-1, j:j+M-1) = uint8(Bloque_V);
                            %   Incrementa en 1 el número de bloques predichos
                            total_verticales = total_verticales + 1;
                        case SAE_H
                            Prediccion(i:i+M-1, j:j+M-1) = uint8(Bloque_H);
                            %   Incrementa en 1 el número de bloques predichos
                            total_horizontales = total_horizontales + 1;
                        otherwise
                            Prediccion(i:i+M-1, j:j+M-1) = uint8(Bloque_DC);
                            %   Incrementa en 1 el número de bloques predichos
                            total_dc = total_dc + 1;
                    end % switch
                end % if
            end % for
        end % for
    end % if
    
    %   Imagen diferencia
    Diferencia = double(Luminancia) - double(Prediccion);
    %   Imagen error
    Error = uint8(abs(Diferencia));
    %   RMS del error
    RMS = round(sqrt(mean(Diferencia(:).^2)) * 100) / 100;

end

