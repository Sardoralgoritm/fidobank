<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, java.text.DecimalFormat, uz.ssardor.bank.Account" %>
<%
    List<Account> accounts = (List<Account>) request.getAttribute("accounts");
    String ok  = (String) request.getAttribute("ok");
    String err = (String) request.getAttribute("err");
    DecimalFormat money = new DecimalFormat("#,##0.00");
%>
<!doctype html>
<html lang="uz">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>FidoBank demo</title>
<style>
  :root{
    --ink:#16181d; --muted:#5b6472; --line:#dfe3e9;
    --paper:#fff; --ground:#f2f4f7; --brand:#a71f38;
    --ok:#0f6b5c; --ok-bg:#e2f1ed; --err:#a71f38; --err-bg:#fbe9ec;
  }
  *{box-sizing:border-box}
  body{margin:0;background:var(--ground);color:var(--ink);
       font-family:'Segoe UI',system-ui,sans-serif;line-height:1.5}
  .wrap{max-width:760px;margin:0 auto;padding:28px 18px 60px}
  header{border-bottom:2px solid var(--ink);padding-bottom:14px;margin-bottom:22px}
  h1{margin:0 0 4px;font-size:26px;letter-spacing:-.01em}
  .sub{margin:0;color:var(--muted);font-size:13.5px}
  .stack{font-family:Consolas,monospace;font-size:11.5px;color:var(--brand);
         letter-spacing:.04em;margin-top:6px}
  .card{background:var(--paper);border:1px solid var(--line);border-radius:8px;
        padding:16px 18px;margin-bottom:16px}
  h2{margin:0 0 12px;font-size:15px;text-transform:uppercase;
     letter-spacing:.07em;color:var(--muted)}
  table{border-collapse:collapse;width:100%;font-size:14.5px}
  th{text-align:left;font-size:11px;text-transform:uppercase;letter-spacing:.06em;
     color:var(--muted);border-bottom:1px solid var(--line);padding:0 8px 6px 0}
  td{padding:8px 8px 8px 0;border-bottom:1px solid #f0f2f5}
  td.num{text-align:right;font-variant-numeric:tabular-nums;font-weight:600}
  td.id{font-family:Consolas,monospace;color:var(--muted)}
  form{display:grid;grid-template-columns:1fr 1fr 1fr auto;gap:10px;align-items:end}
  label{display:block;font-size:11px;text-transform:uppercase;letter-spacing:.06em;
        color:var(--muted);margin-bottom:4px}
  select,input{width:100%;padding:8px 10px;border:1px solid var(--line);
               border-radius:5px;font-size:14px;font-family:inherit;background:#fff}
  button{padding:9px 18px;background:var(--brand);color:#fff;border:0;
         border-radius:5px;font-size:14px;font-weight:600;cursor:pointer}
  button:hover{background:#8c1a2f}
  .msg{padding:10px 14px;border-radius:6px;font-size:14px;margin-bottom:16px}
  .msg.ok{background:var(--ok-bg);color:var(--ok);border:1px solid #b8ddd4}
  .msg.err{background:var(--err-bg);color:var(--err);border:1px solid #f0c4cc}
  footer{margin-top:26px;font-size:12.5px;color:var(--muted);
         border-top:1px solid var(--line);padding-top:14px}
  @media (max-width:620px){form{grid-template-columns:1fr}}
</style>
</head>
<body>
<div class="wrap">

  <header>
    <h1>FidoBank demo</h1>
    <p class="sub">Pul o&#699;tkazma. Biznes mantiq to&#699;liq PL/SQL paketida.</p>
    <p class="stack">JSP &middot; SERVLET &middot; JDBC &middot; TOMCAT 9 &middot; ORACLE XE 21c &middot; DOCKER</p>
  </header>

<% if (ok != null) { %>
  <div class="msg ok"><%= ok %></div>
<% } %>
<% if (err != null) { %>
  <div class="msg err"><%= err %></div>
<% } %>

  <div class="card">
    <h2>Hisoblar</h2>
    <table>
      <thead><tr><th>Hisob</th><th>Egasi</th><th style="text-align:right">Qoldiq</th></tr></thead>
      <tbody>
<% for (Account a : accounts) { %>
        <tr>
          <td class="id"><%= a.id() %></td>
          <td><%= a.owner() %></td>
          <td class="num"><%= money.format(a.bal()) %></td>
        </tr>
<% } %>
<% if (accounts.isEmpty()) { %>
        <tr><td colspan="3" style="color:#5b6472">Ma&#699;lumot yo&#699;q</td></tr>
<% } %>
      </tbody>
    </table>
  </div>

  <div class="card">
    <h2>O&#699;tkazma</h2>
    <form method="post" action="<%= request.getContextPath() %>/">
      <div>
        <label for="from">Kimdan</label>
        <select name="from" id="from">
<% for (Account a : accounts) { %>
          <option value="<%= a.id() %>"><%= a.id() %> &mdash; <%= a.owner() %></option>
<% } %>
        </select>
      </div>
      <div>
        <label for="to">Kimga</label>
        <select name="to" id="to">
<% for (Account a : accounts) { %>
          <option value="<%= a.id() %>"><%= a.id() %> &mdash; <%= a.owner() %></option>
<% } %>
        </select>
      </div>
      <div>
        <label for="amount">Summa</label>
        <input type="text" name="amount" id="amount" value="100000" inputmode="decimal">
      </div>
      <button type="submit">O&#699;tkazish</button>
    </form>
  </div>

  <footer>
    Deadlock&#699;ning oldini olish uchun lock&#699;lar har doim <code>id</code> bo&#699;yicha
    o&#699;sish tartibida olinadi. Xatolar autonomous transaction bilan
    <code>err_log</code> jadvaliga yoziladi.
  </footer>

</div>
</body>
</html>
