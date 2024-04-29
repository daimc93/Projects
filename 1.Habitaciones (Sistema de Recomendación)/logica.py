import numpy as np
import pandas as pd
from sklearn.preprocessing import OneHotEncoder

#Carga de los datos
df = pd.read_csv('dataset_inquilinos.csv', index_col = 'id_inquilino')

df.columns = ['horario', 'bioritmo', 'nivel_educativo', 'leer', 'animacion', 'cine', 'mascotas', 'cocinar', 'deporte', 'dieta', 'fumador',
'visitas', 'orden', 'musica_tipo', 'musica_alta', 'plan_perfecto', 'instrumento']

#One hot encoding
encoder = OneHotEncoder(sparse=False)
df_encoded = encoder.fit_transform(df)

#Obtener nombres de las variables codificadas despues de realizar el one-hot encoding
encoded_feature_names = encoder.get_feature_names_out()

#Calcular matriz de similaridad utilizando producto punto
matriz_s = np.dot(df_encoded, df_encoded.T)

#Definir rango de destino
rango_min = -100
rango_max = 100

#Encontrar el min y el max en la matriz_s
min_original = np.min(matriz_s)
max_original = np.max(matriz_s)

#Reescalar la matriz
matriz_s_reescalada = ((matriz_s - min_original) / (max_original - min_original)) * (rango_max - rango_min) + rango_min

#Pasar a pandas
df_similaridad = pd.DataFrame(matriz_s_reescalada, index=df.index, columns=df.index)

#Busqueda de inquilinos compatibles

'''
Input:
* id_inquilinos: el o los inquilinos actuales DEBE SER UNA LISTA aunque sea solo un dato
* topn: el número de inquilinos compatibles a buscar

Output:
Lista con 2 elementos.
Elemento 0: las características de los inquilinos compatibles
Elemento 1: el dato de similaridad
'''
def inquilinos_compatibles(id_inquilinos, topn):
    #Verificar que los id_inquelinos ingresados esten en la matriz de similaridad
    for id_inquilino in id_inquilinos:
        if id_inquilino not in df_similaridad.index:
            return 'Al menos uno de los inquilinos no fue encontrado'
        
    #Obtener las filas correspondientes a los inquilinos ingresados
    filas_inquilinos = df_similaridad.loc[id_inquilinos]

    #Calcular la similitud promedio entre los inquilinos
    similitud_prom = filas_inquilinos.mean(axis=0)

    #Ordenar los inquilinos en funcion de su similitud promedio
    inquilinos_similares = similitud_prom.sort_values(ascending=False)

    #Excluir los inquilinos de referencia
    inquilinos_similares = inquilinos_similares.drop(id_inquilinos)

    #Tomar los topn inqulinos mas similares
    topn_inquilinos = inquilinos_similares.head(topn)

    #Obtener los registros de los inquilinos similares
    registros_similares = df.loc[topn_inquilinos.index]

    #Obtener los registros de los inquilinos ingresados
    registros_ingresados = df.loc[id_inquilinos]

    #Concatenar los dos registros 
    result = pd.concat([registros_ingresados.T, registros_similares.T], axis=1)

    #Crear un objero Series con la similitud de los inquilinos similares encontrados
    similitud_series = pd.Series(data=topn_inquilinos.values, index=topn_inquilinos.index, name='Similitud')

    return(result, similitud_series)


