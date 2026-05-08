import matplotlib.pyplot as plt
import matplotlib.patches as patches

def crear_diagrama_chen():
    # Crear lienzo
    fig, ax = plt.subplots(figsize=(16, 12))
    ax.set_xlim(0, 20)
    ax.set_ylim(0, 15)
    ax.axis('off')

    # --- 1. FUNCIÓN PARA LÍNEAS DE CONEXIÓN ---
    def conectar(x1, y1, x2, y2):
        ax.plot([x1, x2], [y1, y2], color='black', lw=1.5, zorder=1)

    # Conexiones USUARIO
    conectar(5, 11, 3, 12.5) # nombre_usuario
    conectar(5, 11, 7, 12.5) # contraseña
    conectar(5, 11, 5, 7.5)  # A relacion Tiene

    # Conexiones EMPLEADO
    conectar(5, 4, 2, 5.5) # Codigo
    conectar(5, 4, 2, 4.5) # Nombre
    conectar(5, 4, 2, 3.5) # Direccion
    conectar(5, 4, 2, 2.5) # Telefono
    conectar(5, 4, 5, 2)   # Sexo
    conectar(5, 4, 8, 2.5) # Fecha_nac
    conectar(5, 4, 8, 3.5) # Turno
    conectar(5, 4, 5, 7.5) # A relacion Tiene
    conectar(5, 4, 10, 7.5) # A relacion Presta

    # Conexiones LIBRO
    conectar(15, 11, 13, 13) # ISBN
    conectar(15, 11, 15, 13.5) # Titulo
    conectar(15, 11, 17, 13) # Autor
    conectar(15, 11, 18, 11) # Editorial
    conectar(15, 11, 10, 7.5) # A relacion Presta

    # Conexiones LECTOR
    conectar(15, 4, 18, 5.5) # ID
    conectar(15, 4, 18, 4.5) # Nombre
    conectar(15, 4, 18, 3.5) # Telefono
    conectar(15, 4, 15, 2)   # Estatus
    conectar(15, 4, 10, 7.5) # A relacion Presta

    # Conexiones Atributos de PRESTA (En Notación Chen las relaciones pueden tener atributos)
    conectar(10, 7.5, 10, 9.5) # Fecha Salida
    conectar(10, 7.5, 10, 5.5) # Fecha Devolucion

    # --- 2. FUNCIONES PARA DIBUJAR FIGURAS ---
    def dibujar_entidad(x, y, texto):
        rect = patches.Rectangle((x-1.5, y-0.6), 3, 1.2, fill=True, color='#FFD966', ec='black', lw=1.5, zorder=2)
        ax.add_patch(rect)
        ax.text(x, y, texto, ha='center', va='center', weight='bold', fontsize=11, zorder=3)

    def dibujar_atributo(x, y, texto, es_pk=False):
        elip = patches.Ellipse((x, y), 2.5, 0.8, fill=True, color='white', ec='black', lw=1.5, zorder=2)
        ax.add_patch(elip)
        if es_pk:
            ax.text(x, y, texto, ha='center', va='center', fontsize=9, zorder=3)
            # Subrayar Llave Primaria (PK)
            ax.plot([x-0.8, x+0.8], [y-0.15, y-0.15], color='black', lw=1.2, zorder=3) 
        else:
            ax.text(x, y, texto, ha='center', va='center', fontsize=9, zorder=3)

    def dibujar_relacion(x, y, texto):
        poly = patches.Polygon([[x, y+0.8], [x+1.5, y], [x, y-0.8], [x-1.5, y]], fill=True, color='#E0F2F1', ec='#00838F', lw=1.5, zorder=2)
        ax.add_patch(poly)
        ax.text(x, y, texto, ha='center', va='center', weight='bold', fontsize=10, zorder=3)

    # --- 3. PLASMAR ELEMENTOS EN EL LIENZO ---
    
    # Entidades (Rectángulos)
    dibujar_entidad(5, 11, "USUARIO")
    dibujar_entidad(5, 4, "EMPLEADO")
    dibujar_entidad(15, 11, "LIBRO")
    dibujar_entidad(15, 4, "LECTOR")

    # Relaciones (Rombos)
    dibujar_relacion(5, 7.5, "Tiene")
    dibujar_relacion(10, 7.5, "Presta")

    # Cardinalidades (Texto flotante)
    ax.text(5.2, 10, "(1,1)", fontsize=10, weight='bold', color='darkred')
    ax.text(5.2, 5, "(1,1)", fontsize=10, weight='bold', color='darkred')
    ax.text(6.8, 5, "(1,N)", fontsize=10, weight='bold', color='darkred')
    ax.text(13.2, 10, "(1,N)", fontsize=10, weight='bold', color='darkred')
    ax.text(13.2, 5, "(1,N)", fontsize=10, weight='bold', color='darkred')

    # Atributos USUARIO
    dibujar_atributo(3, 12.5, "nombre_usuario", es_pk=True)
    dibujar_atributo(7, 12.5, "contraseña")

    # Atributos EMPLEADO
    dibujar_atributo(2, 5.5, "Codigo", es_pk=True)
    dibujar_atributo(2, 4.5, "Nombre")
    dibujar_atributo(2, 3.5, "Direccion")
    dibujar_atributo(2, 2.5, "Telefono")
    dibujar_atributo(5, 2, "Sexo")
    dibujar_atributo(8, 2.5, "Fecha_nac")
    dibujar_atributo(8, 3.5, "Turno")

    # Atributos LIBRO
    dibujar_atributo(13, 13, "ISBN", es_pk=True)
    dibujar_atributo(15, 13.5, "Titulo")
    dibujar_atributo(17, 13, "Autor")
    dibujar_atributo(18, 11, "Editorial")

    # Atributos LECTOR
    dibujar_atributo(18, 5.5, "ID_Lector", es_pk=True)
    dibujar_atributo(18, 4.5, "Nombre")
    dibujar_atributo(18, 3.5, "Telefono")
    dibujar_atributo(15, 2, "Estatus")

    # Atributos PRESTA
    dibujar_atributo(10, 9.5, "Fecha_Salida")
    dibujar_atributo(10, 5.5, "Fecha_Dev")

    # Título General
    plt.title("Modelo Entidad-Relación (Notación de Chen): Biblioteca", fontsize=16, weight='bold', pad=20)
    plt.tight_layout()
    plt.show()

if __name__ == '__main__':
    crear_diagrama_chen()