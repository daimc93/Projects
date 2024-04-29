import matplotlib.pyplot as plt
import seaborn as sns
import plotly.graph_objs as go
import streamlit as st

#FUNCION PARA GENERAR EL GRAFICO DE COMPATIBILIDAD
def generar_grafico(compatibilidad):
    compatibilidad = compatibilidad/100     #Escala de 0 a 1 para porcentajes

    #Configuracion grafico Seaborn
    fig,ax = plt.subplots(figsize=(5,4))    #Ajuste del tamaño del grafico

    #Creacion del grafico de barras con valores en porcentaje
    sns.barplot(x=compatibilidad.index, y=compatibilidad.values, ax=ax, color='lightblue', edgecolor=None)

    #Quitar bordes
    sns.despine(top=True, right=True, left=True, bottom=False)

    #Configuracion de etiquetas de los ejes y rotar las etiquetas del eje x
    ax.set_xlabel('Identificador de Inquilino', fontsize=10)
    ax.set_ylabel('Similitud(%)', fontsize=10)
    ax.set_xticklabels(ax.get_xticklabels(), rotation=45)

    #Ajuste etiquetas del eje y para mostrar porcentajes correctamente
    ax.set_yticklabels(['{:.1f}'.format(y*100) for y in ax.get_yticks()], fontsize=8)

    #Etiquetas de porcentaje sobre cada barra
    for p in ax.patches:
        height = p.get_height()
        ax.annotate('{:.1f}%'.format(height*100), (p.get_x()+p.get_width() / 2., height),
                    ha='center', va='center', xytext=(0,5), textcoords='offset points', fontsize=8)
    return(fig)

#FUNCION PARA GENERAR LA TABLA DE COMPAÑEROS
def generar_tabla_compatibilidad(resultado):
    #cambiar el nombre de la columna 'index' y ajustar el ancho de las columnas
    resultado_0_with_index = resultado[0].reset_index()
    resultado_0_with_index.rename(columns={'index':'ATRIBUTO'}, inplace=True)
    
    #Configuracion tabla de Plotly
    fig_table = go.Figure(data = [go.Table(columnwidth=[20]+[10]*(len(resultado_0_with_index.columns)-1),
                                           header=dict(values=list(resultado_0_with_index.columns), 
                                                       fill_color='paleturquoise',
                                                       align='left'),
                                            cells=dict(values=[resultado_0_with_index[col] for col in resultado_0_with_index.columns],
                                                       fill_color='lavender',
                                                       align='left'))])
    
    #Configuracion layout tabla de plotly
    fig_table.update_layout(width=700, height=320, margin=dict(l=0, r=0, t=0, b=0))

    return(fig_table)

#FUNCION PARA GENERAR LA LISTA DE INQUILINOS SEMILLA
def obtener_id_inquilinos(inquilino1, inquilino2, inquilino3):
    #Crear una lista con los identificadores de inquilinos ingresados y convertirlos a entero
    id_inquilinos = []
    for inquilino in [inquilino1, inquilino2, inquilino3]:
        try:
            if inquilino:       #Si hay algun texto en el input
                id_inquilinos.append(int(inquilino))       #Convierte a entero y agrega a la lista
        except ValueError:        
            st.error(f"El identificador del inquilino '{inquilino}' no es un número válido.")
            id_inquilinos = []  #vaciar la lista si hay un error
            break   
    return(id_inquilinos)















