package uz.ssardor.bank;

import java.math.BigDecimal;

public record Account(long id, String owner, BigDecimal bal) {
}
