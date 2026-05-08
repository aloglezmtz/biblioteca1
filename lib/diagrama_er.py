import matplotlib.pyplot as plt
import matplotlib.patches as patches

def draw_table(ax, x, y, title, attributes, bg_color):
    """Función para dibujar las tablas de la base de datos"""
    width = 3.8
    height = 0.6 + len(attributes) * 0.35
    
    # Dibujar la caja (sombra + fondo)
    ax.add_patch(patches.Rectangle((x+0.05, y-height-0.05), width, height, fill=True, color='gray', alpha=0.3))
    ax.add_patch(patches.Rectangle((x, y-height), width, height, fill=True, color=bg_color, ec='black', lw=1.5))
    
    # Título de la tabla
    ax.text(x + width/2, y - 0.35, title, fontsize=11, weight='bold', ha='center', color='black')
    ax.plot([x, x+width], [y-0.6, y-0.6], color='black', lw=1.5) # Línea separadora
    
    # Atributos de la tabla
    for i, attr in enumerate(attributes):
        # Diferenciar PK y FK con negritas
        weight = 'bold' if 'PK' in attr or 'FK' in attr else 'normal'
        ax.text(x + 0.2, y - 0.95 - (i*0.35), attr, fontsize=9, family='monospace', weight=weight)

def crear_diagrama():
    fig, ax = plt.subplots(figsize=(15, 10))
    ax.set_xlim(0, 16)
    ax.set_ylim(0, 12)
    ax.axis('off') # Ocultar ejes

    # 1. TABLAS DEL AVANCE 1 (Color Verde)
    draw_table(ax, 1, 11, "USUARIO (Login)", 
               ["PK  nombre_del_usuario", "    contraseña", "FK  codigo_empleado"], "#D9EAD3")
    
    draw_table(ax, 1, 7, "EMPLEADO (Personal)", 
               ["PK  Codigo", "    Nombre", "    Dirección", "    Teléfono", "    Sexo", "    Fecha_nac", "    Turno"], "#D9EAD3")

    # 2. TABLAS DEL SISTEMA COMPLETO (Color Azul)
    draw_table(ax, 11, 11, "LIBRO / ARCHIVO (Búsqueda)", 
               ["PK  ISBN / ID_Archivo", "    Titulo", "    Autor", "    Categoria", "    Ubicacion_Estante", "    Disponibilidad"], "#C9DAF8")
    
    draw_table(ax, 11, 7, "LECTOR (Visitante)", 
               ["PK  ID_Lector", "    Nombre", "    Matricula", "    Telefono", "    Estatus"], "#C9DAF8")

    # 3. TABLA RELACIONAL DE TRANSACCIONES (Color Amarillo)
    draw_table(ax, 6, 5, "PRESTAMO (Transacción)", 
               ["PK  ID_Prestamo", "FK  Codigo_Empleado", "FK  ISBN_Libro", "FK  ID_Lector", "    Fecha_Salida", "    Fecha_Devolucion"], "#FFF2CC")

    # --- DIBUJAR LÍNEAS DE RELACIÓN ---
    arrow_props = dict(arrowstyle="->", color="black", lw=2)

    # Relación: Usuario -> Empleado (1 a 1)
    ax.annotate("", xy=(2.9, 7), xytext=(2.9, 8.8), arrowprops=arrow_props)
    ax.text(3.1, 7.8, "1:1 Pertenece a", rotation=90, fontsize=9, color="darkred", weight="bold")

    # Relación: Empleado -> Prestamo (1 a N)
    ax.annotate("", xy=(6, 4.5), xytext=(4.8, 4.5), arrowprops=arrow_props)
    ax.text(5, 4.7, "1:N Registra", fontsize=9, color="darkred", weight="bold")

    # Relación: Lector -> Prestamo (1 a N)
    ax.annotate("", xy=(9.8, 4.5), xytext=(11, 5), arrowprops=arrow_props)
    ax.text(9.9, 5, "1:N Solicita", fontsize=9, color="darkred", weight="bold", rotation=30)

    # Relación: Libro -> Prestamo (1 a N)
    ax.annotate("", xy=(8, 5), xytext=(11, 8.5), arrowprops=arrow_props)
    ax.text(8.5, 7, "1:N Se presta en", fontsize=9, color="darkred", weight="bold", rotation=-45)

    # --- TEXTOS EXPLICATIVOS ---
    ax.text(8, 11.5, "DIAGRAMA ER COMPLETO: SISTEMA DE BIBLIOTECA", 
            fontsize=18, weight='bold', ha='center', color='indigo')
    ax.text(8, 11, "(Incluye requerimientos de Avance 1 + Flujo de búsquedas y préstamos)", 
            fontsize=11, ha='center', color='gray')
    
    plt.tight_layout()
    plt.show()

if __name__ == '__main__':
    crear_diagrama()