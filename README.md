# JupyterLab Numeric Stack
Combine every (mainly numerical) solver possible into one jupyter lab

# Quickstart

1. Install Docker
2. Clone rep
3. Open rep folder in terminal
4. Type "docker build -t scientific-notebook -f Dockerfile ."
5. Type "docker run -it --rm -p 8888:8888 scientific-notebook"
6. Open localhost:8888 in your local browser (or open the link showing in your console "http://127.0.0.1:8888/lab?token=your-pass-key" by clicking while holding ctrl)

# Featuring

## [Julia](https://julialang.org/)

## [Pluto.jl](https://plutojl.org/)
Simple, reactive programming environment for Julia

## Numpy/Scipy/matplotlib etc. (Python, ipykernel)

## Python ([XPython](https://github.com/jupyter-xeus/xeus-python))

## [Fenicsx/Dolfinx](https://fenicsproject.org/) (ipykernel)
including Numpy, Scipy, Pyvista etc.

## Matlab

## [Deno](https://deno.com/) (JavaScript, TypeScript)
Using [Fresh](https://fresh.deno.dev/) with deno:

1. add "-p 8000:8000" to the docker run command
2. open terminal in jupyterlab
3. run "deno run -A -r https://fresh.deno.dev"
4. run "cd fresh-project"
5. run "deno task start"
6. open localhost:8000 to view fresh app

## [TSV/CSV-Editor](https://github.com/jupytercalpoly/jupyterlab-tabular-data-editor) (Tables)

## [Myst](https://mystmd.org/)
MyST extends Markdown for technical, scientific communication and publication.

## [Draw.io](https://github.com/QuantStack/jupyterlab-drawio)

## [ipywidgets](https://github.com/jupyter-widgets/ipywidgets/)
Interactive Jupyter labs.

## [ipydatagrid](https://github.com/bloomberg/ipydatagrid)
Fast Datagrid widget for the Jupyter Notebook and JupyterLab

## [Plotly](https://plotly.com/)
Low-Code Python Data Apps

## [Ipygany](https://github.com/jupyter-widgets-contrib/ipygany)
Jupyter Interactive Widgets library for 3-D mesh analysis

## [yFiles](https://www.yworks.com/products/yfiles)
Interactive graph visualization.

## [Archive](https://github.com/jupyterlab-contrib/jupyter-archive) (ZIP)
Download as archive.

## VS Code server



