package uz.ssardor.bank;

import oracle.jdbc.OracleTypes;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/")
public class BankServlet extends HttpServlet {

    private static final String FLASH_OK = "flashOk";
    private static final String FLASH_ERR = "flashErr";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String ok = null;
        String err = null;
        HttpSession session = req.getSession(false);
        if (session != null) {
            ok = (String) session.getAttribute(FLASH_OK);
            err = (String) session.getAttribute(FLASH_ERR);
            session.removeAttribute(FLASH_OK);
            session.removeAttribute(FLASH_ERR);
        }
        render(req, resp, ok, err);
    }

    /**
     * POST/Redirect/GET. Javobni to'g'ridan-to'g'ri chizsak, brauzerda URL POST
     * holatida qoladi va F5 o'tkazmani qaytadan yuboradi. Redirect'dan keyin
     * F5 faqat GET'ni takrorlaydi.
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String ok = null;
        String err = null;
        try {
            long from = Long.parseLong(req.getParameter("from").trim());
            long to = Long.parseLong(req.getParameter("to").trim());
            BigDecimal amount = new BigDecimal(req.getParameter("amount").trim());
            transfer(from, to, amount);
            ok = "O'tkazma bajarildi: " + amount.toPlainString() + " so'm";
        } catch (NullPointerException | NumberFormatException e) {
            err = "Ma'lumot noto'g'ri kiritildi";
        } catch (SQLException e) {
            err = clean(e.getMessage());
        }

        HttpSession session = req.getSession();
        session.setAttribute(FLASH_OK, ok);
        session.setAttribute(FLASH_ERR, err);
        resp.sendRedirect(req.getContextPath() + "/");
    }

    /** PL/SQL procedurani chaqiradi. ? belgilari bind variable. */
    private void transfer(long from, long to, BigDecimal amount) throws SQLException {
        try (Connection c = Db.ds().getConnection();
             CallableStatement cs = c.prepareCall("{ call pkg_bank.transfer(?, ?, ?) }")) {
            cs.setLong(1, from);
            cs.setLong(2, to);
            cs.setBigDecimal(3, amount);
            cs.execute();
        }
    }

    /** PL/SQL funksiyasidan SYS_REFCURSOR olib, ResultSet qilib o'qiydi. */
    private List<Account> accounts() throws SQLException {
        List<Account> out = new ArrayList<>();
        try (Connection c = Db.ds().getConnection();
             CallableStatement cs = c.prepareCall("{ ? = call pkg_bank.get_accounts }")) {
            cs.registerOutParameter(1, OracleTypes.CURSOR);
            cs.execute();
            try (ResultSet rs = (ResultSet) cs.getObject(1)) {
                while (rs.next()) {
                    out.add(new Account(rs.getLong("id"),
                                        rs.getString("owner"),
                                        rs.getBigDecimal("bal")));
                }
            }
        }
        return out;
    }

    private void render(HttpServletRequest req, HttpServletResponse resp, String ok, String err)
            throws ServletException, IOException {
        try {
            req.setAttribute("accounts", accounts());
        } catch (SQLException e) {
            req.setAttribute("accounts", List.of());
            err = (err == null ? "" : err + " | ") + "Baza bilan aloqa yo'q: " + clean(e.getMessage());
        }
        req.setAttribute("ok", ok);
        req.setAttribute("err", err);
        resp.setCharacterEncoding("UTF-8");
        req.getRequestDispatcher("/WEB-INF/views/bank.jsp").forward(req, resp);
    }

    /** ORA-20012: Mablag' yetarli emas -> "Mablag' yetarli emas" */
    private static String clean(String message) {
        if (message == null) {
            return "Noma'lum xato";
        }
        String first = message.split("\\R")[0].trim();
        int colon = first.indexOf(": ");
        if (first.startsWith("ORA-200") && colon > 0) {
            return first.substring(colon + 2);
        }
        return first;
    }
}
