function [ RMS, ceros_porcentaje, Imagen_Recuperada, Imagen_Error ] = quantizationES( file, escala )
%   lang: ES
%
%   Cuantificador de imágenes tipo Intra según el estándar MPEG-1
%   Calcula la DCT de una imagen y cuantifica los coeficientes
%
%   Parámetros:
%       file: Nombre del archivo de imagen
%       escala: Factor de escala de cuantificación
%   Devuelve:
%       RMS: Valor cuadrático medio del error de cuantificación
%       ceros_porcentaje: Porcentaje de coeficientes cuantificados nulos
%       Imagen_Recuperada: Imagen recuperada (uint8)
%       Imagen_Error: Imagen de error de cuantificación (uint8)

    %   Control errores
    if(mod(escala,2) ~= 0 || escala < 2 || escala > 62)
        fprintf('Valores no utilizados por el estándar MPEG-1')
        return;
    end

    %   Valores predeterminados MPEG-1
    M = 8;
    %   Almacena la imagen en tipo double
    Imagen_Original = imread(file);
    %   Convierte a tipo double y resta 128
    Imagen_Convertida = double(Imagen_Original) - 128;
    %   Almacena el tamaño
    [ancho, alto] = size(Imagen_Original);
    %   Inicializa imagen final
    Imagen_Recuperada = uint8(zeros(ancho, alto));
    %   Coeficientes nulos
    ceros = 0;
    %   Matriz de pesos MPEG-1
    pesos = [8 16 19 22 26 27 29 34;
            16 16 22 24 27 29 34 37;
            19 22 26 27 29 34 34 38;
            22 22 26 27 29 34 37 40;
            22 26 27 29 32 35 40 48;
            26 27 29 32 35 40 48 58;
            26 27 29 34 38 46 56 69
            27 29 35 38 46 56 69 83];

    %   Proceso por bloques
    for i = 1:M:ancho
        for j = 1:M:alto
            %   Construye el bloque
            Bloque = Imagen_Convertida(i:i+M-1, j:j+M-1);
            
            %   DCT
            Bloque_DCT = dct2(Bloque);
            %   Almacena el valor absoulto
            Bloque_DCT_Abs = abs(Bloque_DCT);
            %   Almacena el signo
            Bloque_DCT_Sig = sign(Bloque_DCT);
            
            %   Cuantificación
            Bloque_Cuantificado_Doubles = (Bloque_DCT_Abs ./ pesos) * (8 / escala);
            %   Redondeo a la baja cuando un intervalo es del tipo n + 0.5
            for m = 1:M
                for n = 1:M
                    if(round(Bloque_Cuantificado_Doubles(m, n)) - Bloque_Cuantificado_Doubles(m, n) == 0.5)
                        Bloque_Cuantificado_Doubles(m, n) = ceil(Bloque_Cuantificado_Doubles(m, n)) - 1;
                    end % if
                end % for
            end % for
            Bloque_Cuantificado = round(Bloque_Cuantificado_Doubles);
            %   Procesa de forma independiente el coeficiente de continua
            Bloque_Cuantificado(1,1) = round(Bloque_DCT_Abs(1, 1) / 8);
            
            %   Porcentaje de ceros
            for k = 1:M
                for l = 1:M
                    if (Bloque_Cuantificado(k, l) == 0)
                        ceros = ceros + 1;
                    end % if
                end % for
            end % for
            
            %   Descuantificación
            Bloque_Recuperado_Abs = ceil(Bloque_Cuantificado .* pesos * escala / 8) - 1;
            %   Procesa de forma independiente el coeficiente de continua
            Bloque_Recuperado_Abs(1,1) = Bloque_Cuantificado(1, 1) * 8;
            
            %   DCT inversa
            Bloque_Recuperado = Bloque_DCT_Sig .* Bloque_Recuperado_Abs;
            Bloque_IDCT = idct2(Bloque_Recuperado);
            
            %   Construye imagen final bloque a bloque
            Imagen_Recuperada(i:i+M-1, j:j+M-1) = uint8(Bloque_IDCT + 128);
        end % for
    end % for
    
    %   Imagen diferencia
    Imagen_Diferencia = double(Imagen_Original) - double(Imagen_Recuperada);
    %   Imagen error
    Imagen_Error = uint8(abs(Imagen_Diferencia));
    %   RMS del error
    RMS = round(sqrt(mean(Imagen_Diferencia(:).^2)) * 100) / 100;
    %   Porcentaje de ceros
    ceros_porcentaje = round(ceros * 10000 / (ancho * alto)) / 100;

end