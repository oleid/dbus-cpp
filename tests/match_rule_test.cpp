/*
 * Copyright © 2013 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License version 3,
 * as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Thomas Voß <thomas.voss@canonical.com>
 */

#include "org/freedesktop/dbus/match_rule.h"

#include <gtest/gtest.h>

TEST(MatchRule, ConstructingAMatchRuleYieldsCorrectResult)
{
    org::freedesktop::dbus::MatchRule rule;
    rule
    .type(org::freedesktop::dbus::Message::Type::signal)
    .sender("org.freedesktop.DBus")
    .interface("org.freedesktop.DBus")
    .member("ListNames")
    .path(org::freedesktop::dbus::types::ObjectPath("/org/freedesktop/DBus"));

    const std::string expected_rule
    {"type='signal',sender='org.freedesktop.DBus',interface='org.freedesktop.DBus',member='ListNames',path='/org/freedesktop/DBus'"
    };

    EXPECT_EQ(expected_rule, rule.as_string());
}
