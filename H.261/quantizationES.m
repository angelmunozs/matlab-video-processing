function [ RMS, ceros_porcentaje, Imagen_Recuperada, Imagen_Error ] = quantizationES( file, t, q )
%   lang: ES
%
%   Cuantificador de imágenes tipo Intra según el estándar H.261
%   Calcula la DCT de una imagen y cuantifica los coeficientes
%
%   Parámetros:
%       file: Nombre del archivo de imagen
%       t: Umbral de cuantificación
%       q: Escalón de cuantificación
%   Devuelve:
%       RMS: Valor cuadrático medio del error de cuantificación
%       ceros_porcentaje: Porcentaje de coeficientes cuantificados nulos
%       Imagen_Recuperada: Imagen recuperada (uint8)
%       Imagen_Error: Imagen de error de cuantificación (uint8)

    %   Control errores
    if(t < 0 || mod(q,2) ~= 0 || q < 2 || q > 62)
        fprintf('Valores no utilizados por el estándar H.261')
        return;
    end

    %   Valores predeterminados H.261
    M = 8;
    %   Almacena la imagen en tipo double
    Imagen_Original = imread(file);
    %   Convierte a tipo double y resta 128
    Imagen_Convertida = double(Imagen_Original) - 128;
    %   Almacena el tamaño
    [ancho, alto] = size(Imagen_Original);
    %   Inicializa imagen final
    Imagen_Recuperada = uint8(zeros(ancho, alto));
    %   Matriz coeficientes DCT
    T = dctmtx(M);
    %   Coeficientes nulos
    ceros = 0;    

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
            Bloque_Cuantificado = ceil((Bloque_DCT_Abs - t) / q);
            %   Procesa de forma independiente el coeficiente de continua
            Bloque_Cuantificado(1,1) = ceil(Bloque_DCT_Abs(1,1) / 8);
            
            %   Decuantificación
            Bloque_Recuperado_Abs = t + (Bloque_Cuantificado - 1) * q + q/2;
            %   Procesa de forma independiente el coeficiente de continua
            Bloque_Recuperado_Abs(1,1) = (Bloque_Cuantificado(1,1) - 1) * 8 + 4;
            %   Coeficientes nulos
            Bloque_Recuperado_Abs(Bloque_Cuantificado == 0) = 0;
            
            
            %   Porcentaje de ceros
            for k = 1:M
                for l = 1:M
                    if (Bloque_Recuperado_Abs(k, l) == 0)
                        ceros = ceros + 1;
                    end
                end
            end
            %   DCT inversa
            Bloque_Recuperado = Bloque_DCT_Sig .* Bloque_Recuperado_Abs;
            Bloque_IDCT = idct2(Bloque_Recuperado);
            
            %   Construye iamgen final bloque a bloque
            Imagen_Recuperada(i:i+M-1, j:j+M-1) = uint8(Bloque_IDCT + 128);
        end
    end
    
    %   Imagen diferencia
    Imagen_Diferencia = double(Imagen_Original) - double(Imagen_Recuperada);
    %   Imagen error
    Imagen_Error = uint8(abs(Imagen_Diferencia));
    %   RMS del error
    RMS = round(sqrt(mean(Imagen_Diferencia(:).^2)) * 100) / 100;
    %   Porcentaje coeficientes nulos
    ceros_porcentaje = round(ceros / (ancho * alto) * 10000) / 100;
    
end