import React, { useEffect, useMemo, useState } from "react";
import { createRoot } from "react-dom/client";
import { Activity, BatteryCharging, CloudSun, Leaf, Radio, TriangleAlert, Zap } from "lucide-react";
import { Area, AreaChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";
import "./styles.css";

const fallback = [
  { site_id: "DUBLIN-001", device_id: "METER-0001", power_kw: 34.2, voltage: 230.4, battery_soc: 71, solar_generation_kw: 8.1, status: "NORMAL", timestamp: new Date().toISOString() },
  { site_id: "DUBLIN-002", device_id: "METER-0002", power_kw: 58.7, voltage: 229.8, battery_soc: 64, solar_generation_kw: 11.8, status: "NORMAL", timestamp: new Date().toISOString() },
  { site_id: "DUBLIN-003", device_id: "METER-0003", power_kw: 84.1, voltage: 231.1, battery_soc: 48, solar_generation_kw: 5.4, status: "HIGH", timestamp: new Date().toISOString() },
];
const trend = [{t:"00",v:128},{t:"04",v:111},{t:"08",v:182},{t:"12",v:241},{t:"16",v:218},{t:"20",v:164},{t:"24",v:138}];
const apiUrl = import.meta.env.VITE_API_URL || "";

function App() {
  const [devices, setDevices] = useState(fallback);
  const [demo, setDemo] = useState(true);
  useEffect(() => {
    if (!apiUrl) return;
    const load = () => fetch(`${apiUrl}/devices`).then(r => r.ok ? r.json() : Promise.reject()).then(data => { if (data.devices?.length) { setDevices(data.devices); setDemo(false); } }).catch(() => setDemo(true));
    load(); const timer = setInterval(load, 10000); return () => clearInterval(timer);
  }, []);
  const totals = useMemo(() => ({ demand: devices.reduce((n,d)=>n+Number(d.power_kw||0),0), solar: devices.reduce((n,d)=>n+Number(d.solar_generation_kw||0),0), high: devices.filter(d=>d.status==="HIGH").length }), [devices]);
  return <div className="shell">
    <aside><div className="brand"><span><Zap size={21}/></span>SMARTGRID <b>AI</b></div><nav><a className="active"><Activity/>Overview</a><a><Radio/>Live telemetry</a><a><CloudSun/>Analytics</a><a><TriangleAlert/>Alerts</a></nav><div className="system"><i></i><div><strong>System operational</strong><small>AWS eu-west-1</small></div></div></aside>
    <main><header><div><p>ENERGY OPERATIONS</p><h1>Portfolio overview</h1></div><div className="live"><i></i>{demo ? "DEMO DATA" : "LIVE · 10S"}</div></header>
      <section className="metrics">
        <Metric icon={<Zap/>} label="Current demand" value={`${totals.demand.toFixed(1)} kW`} note="Across active devices" />
        <Metric icon={<CloudSun/>} label="Solar generation" value={`${totals.solar.toFixed(1)} kW`} note={`${Math.round(totals.solar/totals.demand*100)}% of demand`} />
        <Metric icon={<BatteryCharging/>} label="Average battery" value={`${Math.round(devices.reduce((n,d)=>n+Number(d.battery_soc||0),0)/devices.length)}%`} note="Fleet state of charge" />
        <Metric icon={<Leaf/>} label="High demand" value={totals.high} note={totals.high ? "Needs attention" : "No active alerts"} alert={totals.high>0}/>
      </section>
      <section className="grid"><article className="chart"><div className="title"><div><p>DEMAND PROFILE</p><h2>Energy consumption</h2></div><span>Today</span></div><ResponsiveContainer width="100%" height={270}><AreaChart data={trend}><defs><linearGradient id="g" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stopColor="#35e7a1" stopOpacity={.35}/><stop offset="100%" stopColor="#35e7a1" stopOpacity={0}/></linearGradient></defs><CartesianGrid stroke="#20312c" vertical={false}/><XAxis dataKey="t" stroke="#6f817a" axisLine={false} tickLine={false}/><YAxis stroke="#6f817a" axisLine={false} tickLine={false}/><Tooltip contentStyle={{background:"#10201b",border:"1px solid #294139",borderRadius:10}}/><Area type="monotone" dataKey="v" stroke="#35e7a1" strokeWidth={3} fill="url(#g)"/></AreaChart></ResponsiveContainer></article>
        <article className="forecast"><p>24-HOUR FORECAST</p><h2>Tomorrow</h2><div className="forecastValue">1.82 <small>MWh</small></div><div className="forecastRow"><span>Expected peak</span><b>18:00</b></div><div className="forecastRow"><span>Predicted cost</span><b>€384</b></div><div className="confidence"><span>MODEL CONFIDENCE</span><b>92%</b></div></article></section>
      <section className="sites"><div className="title"><div><p>DEVICE FLEET</p><h2>Latest telemetry</h2></div><span>{devices.length} devices</span></div><div className="table"><div className="tr head"><span>Site / device</span><span>Demand</span><span>Voltage</span><span>Battery</span><span>Status</span></div>{devices.slice(0,8).map(d=><div className="tr" key={`${d.site_id}-${d.device_id}`}><span><b>{d.site_id}</b><small>{d.device_id}</small></span><span>{Number(d.power_kw).toFixed(1)} kW</span><span>{Number(d.voltage).toFixed(1)} V</span><span>{Number(d.battery_soc).toFixed(0)}%</span><span><em className={d.status?.toLowerCase()}>{d.status}</em></span></div>)}</div></section>
    </main></div>;
}
function Metric({icon,label,value,note,alert}) { return <article className="metric"><div className={alert?"metricIcon warn":"metricIcon"}>{icon}</div><p>{label}</p><h2>{value}</h2><small>{note}</small></article> }
createRoot(document.getElementById("root")).render(<App/>);

