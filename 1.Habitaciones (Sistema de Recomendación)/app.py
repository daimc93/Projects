import streamlit as st
import pandas as pd
from logica import inquilinos_compatibles
from ayudantes import generar_grafico, generar_tabla_compatibilidad, obtener_id_inquilinos

#Configurar la pagina para usar un layout mas amplio
st.set_page_config(layout="wide")

result = None

#Mostrar una imagen en la parte superior
st.image('./Media/portada.png', use_column_width=True)

#Insertar un espacio verticar de 60px
st.markdown(f'<div style="margin-top: 60px;"></div>', unsafe_allow_html=True)

#Configurar el sidebar con inputs y un botón
with st.sidebar:
    st.header("Quien está viviendo ya en el piso")
    inquilino1 = st.text_input("Inquilino 1")
    inquilino2 = st.text_input("Inquilino 2")
    inquilino3 = st.text_input("Inquilino 3")

    num_compañeros = st.text_input("Cuantos compañeros nuevos quiere buscar?")

    if st.button('BUSCAR NUEVOS COMPAÑEROS'):
        #Verifica que el numero de compañeros sea un valor valido
        try:
            topn = int(num_compañeros)
        except ValueError:
            st.error("Por favor, ingrese un valor válido para el número de compañeros")
            topn = None

        #Obtener los identificadores de inquilinos
        id_inquilinos = obtener_id_inquilinos(inquilino1, inquilino2, inquilino3)

        if id_inquilinos and topn is not None:
            result = inquilinos_compatibles (id_inquilinos, topn)

#Verificar si result contiene un mennsaje de error
if isinstance(result, str):
    st.error(result)
#Si no hay str, ni es None, mostrar el grafico de barras y la tabla de compatibilidad
elif result is not None:
    cols = st.columns((1,2))    #Divide el latout en dos columnas
    with cols[0]:   #Para que el gráfico y su titulo aparezcan en la primera columna
        st.write("Nivel de compatibilidad de cada nuevo compañero:")
        fig_grafico = generar_grafico(result[1])
        st.pyplot(fig_grafico)
    with cols[1]:   #Para que la tabla y el titulo aparezcan en la 2da columna
        st.write("Comparativa entre compañeros:")
        fig_tabla = generar_tabla_compatibilidad(result)
        st.plotly_chart(fig_tabla, use_container_width=True)
        