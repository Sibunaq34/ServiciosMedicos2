import axios from 'axios'

const API_BASE_URL = typeof import.meta.env.VITE_API_BASE_URL === 'string' && import.meta.env.VITE_API_BASE_URL.trim()
  ? import.meta.env.VITE_API_BASE_URL.trim()
  : 'http://localhost:5220'

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
})

api.interceptors.request.use((config) => {
  const token = sessionStorage.getItem('token')

  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }

  return config
})

function extraerRespuestaData(responseData) {
  if (!responseData || typeof responseData !== 'object') {
    return {}
  }

  if ('data' in responseData && responseData.data && typeof responseData.data === 'object') {
    return responseData.data
  }

  if ('oferente' in responseData && responseData.oferente && typeof responseData.oferente === 'object') {
    return responseData.oferente
  }

  return responseData
}

export async function obtenerDetalleOferente(idOferente) {
  const id = Number(idOferente ?? 0)

  if (!Number.isFinite(id) || id <= 0) {
    throw new Error('No se recibió un identificador de oferente válido.')
  }

  const urls = [
    `/api/Oferentes/${encodeURIComponent(id)}/detalle`,
    `/api/Oferentes/detalle?idOferente=${encodeURIComponent(id)}`,
    `/api/Oferentes/${encodeURIComponent(id)}`,
    `/api/OferenteDetalle?idOferente=${encodeURIComponent(id)}`,
  ]

  let ultimoError = null

  for (const url of urls) {
    try {
      const response = await api.get(url)
      const detalle = extraerRespuestaData(response.data)

      return {
        ok: true,
        status: response.status,
        data: detalle,
        mensaje: response.data?.mensaje ?? 'Detalle del oferente obtenido correctamente.',
      }
    } catch (error) {
      ultimoError = error
    }
  }

  if (axios.isAxiosError(ultimoError)) {
    const data = ultimoError.response?.data ?? {}
    const mensaje =
      data?.mensaje ??
      data?.message ??
      data?.detail ??
      data?.title ??
      'No fue posible cargar el detalle del oferente.'

    const errorServicio = new Error(mensaje)
    errorServicio.status = ultimoError.response?.status ?? 500
    throw errorServicio
  }

  const errorServicio = new Error('No fue posible cargar el detalle del oferente.')
  errorServicio.status = 500
  throw errorServicio
}

export async function registrarEmpleado(datos) {
  try {
    const payload = {
      idOferente: Number(datos?.idOferente ?? 0),
      codigoPuesto: String(datos?.codigoPuesto ?? '').trim(),
      idUsuario: Number(datos?.idUsuario ?? 0),
      idJefatura: datos?.idJefatura === '' || datos?.idJefatura == null ? null : Number(datos.idJefatura),
    }

    const response = await api.post('/api/Empleados', payload)

    return {
      ok: true,
      status: response.status,
      data: response.data ?? {},
      mensaje: response.data?.mensaje ?? 'Empleado registrado correctamente.',
    }
  } catch (error) {
    if (axios.isAxiosError(error)) {
      const data = error.response?.data ?? {}
      const mensaje =
        data?.mensaje ??
        data?.message ??
        data?.detail ??
        data?.title ??
        'No fue posible registrar el empleado.'

      const errorServicio = new Error(mensaje)
      errorServicio.status = error.response?.status ?? 500
      throw errorServicio
    }

    const errorServicio = new Error('No fue posible registrar el empleado.')
    errorServicio.status = 500
    throw errorServicio
  }
}
