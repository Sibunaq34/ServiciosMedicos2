import { useEffect, useMemo, useState } from 'react'
import { Link, useNavigate, useParams, useSearchParams } from 'react-router-dom'
import { obtenerDetalleOferente, registrarEmpleado } from './DetalleOferenteService'

function leerIdUsuarioActual() {
  try {
    const rawUser = sessionStorage.getItem('user')
    const usuario = rawUser ? JSON.parse(rawUser) : {}
    const valor = Number(usuario.idUsuario ?? usuario.IdUsuario ?? usuario.idusuario ?? 0)
    return Number.isFinite(valor) && valor > 0 ? valor : null
  } catch {
    return null
  }
}

function getValue(obj, ...paths) {
  for (const path of paths) {
    if (!path) {
      continue
    }

    const tokens = path.split('.')
    let current = obj

    for (const token of tokens) {
      if (current == null || !(token in current)) {
        current = undefined
        break
      }
      current = current[token]
    }

    if (current !== undefined && current !== null) {
      return current
    }
  }

  return undefined
}

export default function DetalleOferente() {
  const { codigoOferente } = useParams()
  const navigate = useNavigate()
  const [searchParams] = useSearchParams()

  const [oferente, setOferente] = useState(null)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')
  const [loading, setLoading] = useState(true)
  const [submitting, setSubmitting] = useState(false)
  const [codigoPuesto, setCodigoPuesto] = useState(searchParams.get('codigoPuesto') || '')
  const [idJefatura, setIdJefatura] = useState('')

  const usuarioActual = useMemo(() => {
    const usuario = (() => {
      try {
        const rawUser = sessionStorage.getItem('user')
        return rawUser ? JSON.parse(rawUser) : {}
      } catch {
        return {}
      }
    })()

    return {
      idUsuario: Number(usuario.idUsuario ?? usuario.IdUsuario ?? usuario.idusuario ?? 0),
      nombreCompleto: usuario.nombreCompleto ?? usuario.NombreCompleto ?? usuario.usuario ?? 'Usuario',
    }
  }, [])

  useEffect(() => {
    let activo = true

    async function cargarDetalle() {
      if (!codigoOferente) {
        setError('No se recibió el identificador del oferente.')
        setLoading(false)
        return
      }

      setLoading(true)
      setError('')

      try {
        const response = await obtenerDetalleOferente(codigoOferente)

        if (!activo) {
          return
        }

        const detalle = response?.data ?? response ?? {}
        const puestoCodigo =
          searchParams.get('codigoPuesto') ||
          getValue(detalle, 'puesto.codigoPuesto', 'puesto.codigo_puesto', 'codigoPuesto', 'codigo_puesto') ||
          ''

        setOferente(detalle)
        setCodigoPuesto(puestoCodigo)
      } catch (requestError) {
        if (!activo) {
          return
        }

        const message = requestError?.message || 'No fue posible cargar el detalle del oferente.'
        setError(message)
        setOferente(null)
      } finally {
        if (activo) {
          setLoading(false)
        }
      }
    }

    cargarDetalle()

    return () => {
      activo = false
    }
  }, [codigoOferente, searchParams])

  const volverUrl = codigoPuesto ? `/puestos/${encodeURIComponent(codigoPuesto)}/oferentes` : '/puestos'
  const nombreCompleto = getValue(oferente, 'nombreCompleto', 'nombre_completo', 'NombreCompleto', 'NombreCompleto') || 'Oferente'
  const identificacion = getValue(oferente, 'identificacion', 'identificacionOferente', 'Identificacion') || '-'
  const tipoIdentificacion = getValue(oferente, 'tipoIdentificacion', 'tipo_identificacion', 'TipoIdentificacion') || '-'
  const fechaNacimiento = getValue(oferente, 'fechaNacimiento', 'fecha_nacimiento', 'FechaNacimiento') || '-'
  const correos = Array.isArray(getValue(oferente, 'correos', 'Correos')) ? getValue(oferente, 'correos', 'Correos') : []
  const telefonos = Array.isArray(getValue(oferente, 'telefonos', 'Telefonos')) ? getValue(oferente, 'telefonos', 'Telefonos') : []
  const puesto = getValue(oferente, 'puesto', 'Puesto') ?? {}
  const codigoPuestoDetalle = getValue(puesto, 'codigoPuesto', 'codigo_puesto', 'CodigoPuesto') || codigoPuesto || ''
  const nombrePuesto = getValue(puesto, 'nombrePuesto', 'nombre_puesto', 'NombrePuesto') || 'Sin puesto asociado'
  const curriculo = getValue(oferente, 'curriculum', 'Curriculum') ?? {}
  const nombreArchivo = getValue(curriculo, 'nombreArchivo', 'nombre_archivo', 'NombreArchivo') || 'Sin currículo registrado'
  const mime = getValue(curriculo, 'mime', 'Mime') || '-'
  const tamanio = getValue(curriculo, 'tamanioFormateado', 'tamanio_formateado', 'TamanioFormateado') || '-'
  const yaEsEmpleado = Boolean(getValue(oferente, 'yaEsEmpleado', 'ya_es_empleado', 'YaEsEmpleado'))

  async function manejarRegistro(event) {
    event.preventDefault()

    if (submitting) {
      return
    }

    const idUsuario = leerIdUsuarioActual() ?? usuarioActual.idUsuario

    if (!codigoOferente) {
      setError('No se seleccionó un oferente válido.')
      return
    }

    const puestoSeleccionado = String(codigoPuesto || codigoPuestoDetalle || '').trim()
    if (!puestoSeleccionado) {
      setError('Debe indicar el puesto del oferente para registrar el empleado.')
      return
    }

    if (!idUsuario) {
      setError('No se pudo identificar al usuario autenticado para registrar el empleado.')
      return
    }

    setError('')
    setSuccess('')
    setSubmitting(true)

    try {
      const payload = {
        idOferente: Number(codigoOferente),
        codigoPuesto: puestoSeleccionado,
        idUsuario,
        idJefatura: idJefatura === '' ? null : Number(idJefatura) || null,
      }

      const response = await registrarEmpleado(payload)

      if (response?.status === 201) {
        const mensaje = response?.mensaje || 'Empleado registrado correctamente.'
        setSuccess(mensaje)
        setTimeout(() => {
          navigate(volverUrl, { replace: true })
        }, 800)
        return
      }

      setSuccess(response?.mensaje || 'Empleado registrado correctamente.')
    } catch (requestError) {
      setError(requestError?.message || 'No fue posible registrar el empleado.')
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <section className="core7-page" aria-labelledby="detalle-oferente-title">
      <header className="core7-page-header card">
        <div className="card-body p-4 p-lg-5 d-flex align-items-start gap-3 gap-md-4">
          <span className="core7-page-header-icon" aria-hidden="true">
            <i className="bi bi-person-badge-fill"></i>
          </span>
          <div>
            <p className="core7-page-kicker mb-1">Contratación</p>
            <h1 id="detalle-oferente-title" className="h3 mb-2">Detalle de oferente</h1>
          </div>
        </div>
      </header>

      {success && (
        <div className="alert alert-success mt-4" role="status">{success}</div>
      )}

      {error && (
        <div className="alert alert-danger mt-4" role="alert">{error}</div>
      )}

      {loading ? (
        <div className="card mt-4">
          <div className="card-body text-center py-5">
            <div className="spinner-border text-primary" role="status">
              <span className="visually-hidden">Cargando detalle del oferente...</span>
            </div>
            <p className="mt-3 mb-0 text-secondary">Cargando detalle del oferente...</p>
          </div>
        </div>
      ) : !oferente ? (
        <div className="alert alert-warning mt-4" role="alert">No se encontró el oferente solicitado.</div>
      ) : (
        <>
          <article className="card mt-4">
            <div className="card-body p-4">
              <h2 className="h4 mb-3">{nombreCompleto}</h2>
              <dl className="row mb-0">
                <dt className="col-sm-4">Identificación</dt>
                <dd className="col-sm-8">{identificacion}</dd>
                <dt className="col-sm-4">Tipo</dt>
                <dd className="col-sm-8">{tipoIdentificacion}</dd>
                <dt className="col-sm-4">Fecha de nacimiento</dt>
                <dd className="col-sm-8">{fechaNacimiento}</dd>
              </dl>
            </div>
          </article>

          <div className="row g-4 my-4">
            <div className="col-lg-6">
              <article className="card h-100">
                <div className="card-header">Correos</div>
                <ul className="list-group list-group-flush">
                  {correos.length > 0 ? (
                    correos.map((correo, index) => (
                      <li className="list-group-item" key={`${correo}-${index}`}>{correo}</li>
                    ))
                  ) : (
                    <li className="list-group-item text-secondary">Sin información registrada.</li>
                  )}
                </ul>
              </article>
            </div>

            <div className="col-lg-6">
              <article className="card h-100">
                <div className="card-header">Teléfonos</div>
                <ul className="list-group list-group-flush">
                  {telefonos.length > 0 ? (
                    telefonos.map((telefono, index) => (
                      <li className="list-group-item" key={`${telefono}-${index}`}>{telefono}</li>
                    ))
                  ) : (
                    <li className="list-group-item text-secondary">Sin información registrada.</li>
                  )}
                </ul>
              </article>
            </div>
          </div>

          <div className="row g-4 mb-4">
            <div className="col-lg-6">
              <article className="card h-100">
                <div className="card-header">Puesto seleccionado</div>
                <div className="card-body">
                  {!nombrePuesto || nombrePuesto === 'Sin puesto asociado' ? (
                    <p className="text-secondary mb-0">Sin puesto asociado.</p>
                  ) : (
                    <dl className="row mb-0">
                      <dt className="col-sm-4">Código</dt>
                      <dd className="col-sm-8">{codigoPuestoDetalle || '-'}</dd>
                      <dt className="col-sm-4">Nombre</dt>
                      <dd className="col-sm-8 mb-0">{nombrePuesto}</dd>
                    </dl>
                  )}
                </div>
              </article>
            </div>

            <div className="col-lg-6">
              <article className="card h-100">
                <div className="card-header">Currículo</div>
                <div className="card-body">
                  {nombreArchivo === 'Sin currículo registrado' ? (
                    <p className="text-secondary mb-0">Sin currículo registrado.</p>
                  ) : (
                    <dl className="row mb-0">
                      <dt className="col-sm-4">Archivo</dt>
                      <dd className="col-sm-8">{nombreArchivo}</dd>
                      <dt className="col-sm-4">Tipo</dt>
                      <dd className="col-sm-8">{mime}</dd>
                      <dt className="col-sm-4">Tamaño</dt>
                      <dd className="col-sm-8 mb-0">{tamanio}</dd>
                    </dl>
                  )}
                </div>
              </article>
            </div>
          </div>

          <div className="d-flex justify-content-between align-items-center gap-3 flex-wrap my-4">
            <div className="d-flex gap-2">
              <Link className="btn btn-outline-secondary" to={volverUrl}>Cancelar</Link>
            </div>
          </div>

          {yaEsEmpleado ? (
            <div className="alert alert-info" role="status">Este oferente ya fue convertido en empleado.</div>
          ) : codigoPuestoDetalle || codigoPuesto ? (
            <form onSubmit={manejarRegistro} noValidate>
              <div className="card">
                <div className="card-header">Registrar como empleado</div>
                <div className="card-body">
                  <div className="row g-3">
                    <div className="col-md-6">
                      <label htmlFor="codigoPuesto" className="form-label">Puesto</label>
                      <input
                        id="codigoPuesto"
                        name="codigoPuesto"
                        type="text"
                        className="form-control"
                        value={codigoPuesto || codigoPuestoDetalle || ''}
                        onChange={(event) => setCodigoPuesto(event.target.value)}
                        disabled={submitting}
                      />
                    </div>

                    <div className="col-md-6">
                      <label htmlFor="usuarioActual" className="form-label">Usuario</label>
                      <input
                        id="usuarioActual"
                        name="usuarioActual"
                        type="text"
                        className="form-control"
                        value={usuarioActual.nombreCompleto || 'Usuario'}
                        readOnly
                      />
                    </div>

                    <div className="col-md-6">
                      <label htmlFor="idJefatura" className="form-label">Jefatura (opcional)</label>
                      <input
                        id="idJefatura"
                        name="idJefatura"
                        type="number"
                        className="form-control"
                        value={idJefatura}
                        onChange={(event) => setIdJefatura(event.target.value)}
                        placeholder="Ingrese el ID de la jefatura"
                        disabled={submitting}
                      />
                    </div>
                  </div>
                </div>
                <div className="card-footer bg-white border-0 d-flex gap-2">
                  <button type="submit" className="btn btn-primary" disabled={submitting}>
                    {submitting ? 'Registrando...' : 'Crear empleado'}
                  </button>
                  <Link className="btn btn-outline-secondary" to={volverUrl}>Cancelar</Link>
                </div>
              </div>
            </form>
          ) : (
            <div className="alert alert-warning" role="alert">
              No se recibió el puesto del listado; la creación está deshabilitada.
            </div>
          )}
        </>
      )}
    </section>
  )
}
