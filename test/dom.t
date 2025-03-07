#!/usr/bin/env python3

###############################################################################
#
# Copyright 2016 - 2021, 2023, Thomas Lauf, Paul Beckingham, Federico Hernandez.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# https://www.opensource.org/licenses/mit-license.php
#
###############################################################################

import os
import sys
import unittest

from datetime import datetime, timezone, timedelta

# Ensure python finds the local simpletap module
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from basetest import Timew, TestCase


class TestDOM(TestCase):
    def setUp(self):
        """Executed before each test in the class"""
        self.t = Timew()

    def test_dom_unrecognized(self):
        """Test 'dom.NOPE' which is unrecognized"""
        code, out, err = self.t.runError("get dom.NOPE")
        self.assertIn("DOM reference 'dom.NOPE' is not valid.", err)

    def test_dom_tag_count_zero(self):
        """Test 'dom.tag.count' with zero tags"""
        code, out, err = self.t("get dom.tag.count")
        self.assertEqual('0\n', out)

    def test_dom_tag_count_two(self):
        """Test 'dom.tag.count' with two tags"""
        self.t("start one two")
        code, out, err = self.t("get dom.tag.count")
        self.assertEqual('2\n', out)

    def test_dom_tag_N_none(self):
        """Test 'dom.tag.N' with no data"""
        code, out, err = self.t.runError("get dom.tag.1")
        self.assertIn("DOM reference 'dom.tag.1' is not valid.", err)

    def test_dom_tag_N_two(self):
        """Test 'dom.tag.N' with two tags"""
        self.t("start one two")
        code, out, err = self.t("get dom.tag.2")
        self.assertEqual('two\n', out)

    def test_dom_active_inactive(self):
        """Test 'dom.active' without an active interval"""
        code, out, err = self.t("get dom.active")
        self.assertEqual('0\n', out)

    def test_dom_active_active(self):
        """Test 'dom.active' with an active interval"""
        self.t("start foo")
        code, out, err = self.t("get dom.active")
        self.assertEqual('1\n', out)

    def test_dom_active_tag_count_inactive(self):
        """Test 'dom.active.tag.count' with no active track"""
        code, out, err = self.t.runError("get dom.active.tag.count")
        self.assertIn("DOM reference 'dom.active.tag.count' is not valid.", err)

    def test_dom_active_tag_count_zero(self):
        """Test 'dom.active.tag.count' with zero tags"""
        self.t("start")
        code, out, err = self.t("get dom.active.tag.count")
        self.assertEqual('0\n', out)

    def test_dom_active_tag_count_two(self):
        """Test 'dom.active.tag.count' with two tags"""
        self.t("start one two")
        code, out, err = self.t("get dom.active.tag.count")
        self.assertEqual('2\n', out)

    def test_dom_active_tag_N_none(self):
        """Test 'dom.active.tag.N' with no active track"""
        code, out, err = self.t.runError("get dom.active.tag.1")
        self.assertIn("DOM reference 'dom.active.tag.1' is not valid.", err)

    def test_dom_active_tag_N_zero(self):
        """Test 'dom.active.tag.N' with zero tags"""
        self.t("start")
        code, out, err = self.t.runError("get dom.active.tag.1")
        self.assertIn("DOM reference 'dom.active.tag.1' is not valid.", err)

    def test_dom_active_tag_N_two(self):
        """Test 'dom.active.tag.N' with two tags"""
        self.t("start one two")
        code, out, err = self.t("get dom.active.tag.2")
        self.assertEqual('two\n', out)

    def test_dom_active_start_inactive(self):
        """Test 'dom.active.start' with no active track"""
        code, out, err = self.t.runError("get dom.active.start")
        self.assertIn("DOM reference 'dom.active.start' is not valid.", err)

    def test_dom_active_start_active(self):
        """Test 'dom.active.start' with active track"""
        self.t("start one two")
        code, out, err = self.t("get dom.active.start")
        self.assertRegex(out, r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}')

    def test_dom_active_duration_inactive(self):
        """Test 'dom.active.duration' with no active track"""
        code, out, err = self.t.runError("get dom.active.duration")
        self.assertIn("DOM reference 'dom.active.duration' is not valid.", err)

    def test_dom_active_duration_active(self):
        """Test 'dom.active.duration' with active track"""
        self.t("start one two")
        code, out, err = self.t("get dom.active.duration")
        self.assertRegex(out, r'PT\d+S')

    def test_dom_active_json_inactive(self):
        """Test 'dom.active.json' without an active interval"""
        code, out, err = self.t.runError("get dom.active.json")
        self.assertIn("DOM reference 'dom.active.json' is not valid.", err)

    def test_dom_active_json_active(self):
        """Test 'dom.active.json' with an active interval"""
        self.t("start foo")
        code, out, err = self.t("get dom.active.json")
        self.assertRegex(out, r'{"id":1,"start":"\d{8}T\d{6}Z","tags":\["foo"\]}')

    def test_dom_tracked_count_none(self):
        """Test 'dom.active' without an active interval"""
        code, out, err = self.t("get dom.tracked.count")
        self.assertEqual('0\n', out)


class TestDOMTracked(TestCase):
    def setUp(self):
        """Executed before each test in the class"""
        self.t = Timew()

    def test_dom_tracked_count_some(self):
        """Test 'dom.tracked.count' with an active interval"""
        self.t("track :yesterday one two")
        self.t("start")

        code, out, err = self.t("get dom.tracked.count")
        self.assertEqual('2\n', out)

    def test_dom_tracked_tags_with_emtpy_database(self):
        """Test 'dom.tracked.tags' with empty database"""
        code, out, err = self.t("get dom.tracked.tags")
        self.assertEqual("\n", out)

    def test_dom_tracked_tags_with_no_tags(self):
        """Test 'dom.tracked.tags' with no tags"""
        now_utc = datetime.now(timezone.utc)
        four_hours_before_utc = now_utc - timedelta(hours=4)
        five_hours_before_utc = now_utc - timedelta(hours=5)

        self.t("track {:%Y-%m-%dT%H:%M:%S}Z - {:%Y-%m-%dT%H:%M:%S}Z".format(five_hours_before_utc, four_hours_before_utc))

        code, out, err = self.t("get dom.tracked.tags")
        self.assertEqual("\n", out)

    def test_dom_tracked_tags_with_tags(self):
        """Test 'dom.tracked.tags' with tags"""
        now_utc = datetime.now(timezone.utc)
        two_hours_before_utc = now_utc - timedelta(hours=2)
        three_hours_before_utc = now_utc - timedelta(hours=3)
        four_hours_before_utc = now_utc - timedelta(hours=4)
        five_hours_before_utc = now_utc - timedelta(hours=5)

        self.t("track {:%Y-%m-%dT%H:%M:%S}Z - {:%Y-%m-%dT%H:%M:%S}Z foo".format(five_hours_before_utc, four_hours_before_utc))
        self.t("track {:%Y-%m-%dT%H:%M:%S}Z - {:%Y-%m-%dT%H:%M:%S}Z bar".format(three_hours_before_utc, two_hours_before_utc))

        code, out, err = self.t("get dom.tracked.tags")
        self.assertEqual("bar foo\n", out)

    def test_dom_tracked_tags_with_quoted_tag(self):
        """Test 'dom.tracked.tags' with a tag with quotes"""
        now_utc = datetime.now(timezone.utc)
        two_hours_before_utc = now_utc - timedelta(hours=2)
        three_hours_before_utc = now_utc - timedelta(hours=3)
        four_hours_before_utc = now_utc - timedelta(hours=4)
        five_hours_before_utc = now_utc - timedelta(hours=5)

        self.t("track {:%Y-%m-%dT%H:%M:%S}Z - {:%Y-%m-%dT%H:%M:%S}Z \"with quotes\"".format(five_hours_before_utc, four_hours_before_utc))
        self.t("track {:%Y-%m-%dT%H:%M:%S}Z - {:%Y-%m-%dT%H:%M:%S}Z bar".format(three_hours_before_utc, two_hours_before_utc))

        code, out, err = self.t("get dom.tracked.tags")
        self.assertEqual("bar \"with quotes\"\n", out)

    def test_dom_tracked_tags_filtered_by_time(self):
        """Test 'dom.tracked.tags' with tags filtered by time"""
        now_utc = datetime.now(timezone.utc)
        one_hour_before_utc = now_utc - timedelta(hours=1)
        two_hours_before_utc = now_utc - timedelta(hours=2)
        three_hours_before_utc = now_utc - timedelta(hours=3)
        four_hours_before_utc = now_utc - timedelta(hours=4)
        five_hours_before_utc = now_utc - timedelta(hours=5)

        self.t("track {:%Y-%m-%dT%H:%M:%S}Z - {:%Y-%m-%dT%H:%M:%S}Z foo".format(five_hours_before_utc, four_hours_before_utc))
        self.t("track {:%Y-%m-%dT%H:%M:%S}Z - {:%Y-%m-%dT%H:%M:%S}Z bar".format(three_hours_before_utc, two_hours_before_utc))
        self.t("track {:%Y-%m-%dT%H:%M:%S}Z - {:%Y-%m-%dT%H:%M:%S}Z baz".format(two_hours_before_utc, one_hour_before_utc))

        code, out, err = self.t("get dom.tracked.tags {:%Y-%m-%dT%H:%M:%S}Z - {:%Y-%m-%dT%H:%M:%S}Z".format(five_hours_before_utc, two_hours_before_utc))
        self.assertEqual("bar foo\n", out)

    def test_dom_tracked_tags_filtered_by_tag(self):
        """Test 'dom.tracked.tags' with tags filtered by tag"""
        now_utc = datetime.now(timezone.utc)
        one_hour_before_utc = now_utc - timedelta(hours=1)
        two_hours_before_utc = now_utc - timedelta(hours=2)
        three_hours_before_utc = now_utc - timedelta(hours=3)
        four_hours_before_utc = now_utc - timedelta(hours=4)
        five_hours_before_utc = now_utc - timedelta(hours=5)

        self.t("track {:%Y-%m-%dT%H:%M:%S}Z - {:%Y-%m-%dT%H:%M:%S}Z foo".format(five_hours_before_utc, four_hours_before_utc))
        self.t("track {:%Y-%m-%dT%H:%M:%S}Z - {:%Y-%m-%dT%H:%M:%S}Z bar".format(three_hours_before_utc, two_hours_before_utc))
        self.t("track {:%Y-%m-%dT%H:%M:%S}Z - {:%Y-%m-%dT%H:%M:%S}Z foo baz".format(two_hours_before_utc, one_hour_before_utc))

        code, out, err = self.t("get dom.tracked.tags foo")
        self.assertEqual("baz foo\n", out)

    def test_dom_tracked_ids_with_emtpy_database(self):
        """Test 'dom.tracked.ids' with empty database"""
        code, out, err = self.t("get dom.tracked.tags")
        self.assertEqual("\n", out)

    def test_dom_tracked_ids(self):
        """Test 'dom.tracked.ids'"""
        now_utc = datetime.now(timezone.utc)
        four_hours_before_utc = now_utc - timedelta(hours=4)
        five_hours_before_utc = now_utc - timedelta(hours=5)

        self.t("track {:%Y-%m-%dT%H:%M:%S}Z - {:%Y-%m-%dT%H:%M:%S}Z".format(five_hours_before_utc, four_hours_before_utc))

        code, out, err = self.t("get dom.tracked.ids")
        self.assertEqual("@1 \n", out)

    def test_dom_tracked_ids_filtered_by_time(self):
        """Test 'dom.tracked.ids' filtered by time"""
        now_utc = datetime.now(timezone.utc)
        one_hour_before_utc = now_utc - timedelta(hours=1)
        two_hours_before_utc = now_utc - timedelta(hours=2)
        three_hours_before_utc = now_utc - timedelta(hours=3)
        four_hours_before_utc = now_utc - timedelta(hours=4)
        five_hours_before_utc = now_utc - timedelta(hours=5)

        self.t("track {:%Y-%m-%dT%H:%M:%S}Z - {:%Y-%m-%dT%H:%M:%S}Z foo".format(five_hours_before_utc, four_hours_before_utc))
        self.t("track {:%Y-%m-%dT%H:%M:%S}Z - {:%Y-%m-%dT%H:%M:%S}Z bar".format(three_hours_before_utc, two_hours_before_utc))
        self.t("track {:%Y-%m-%dT%H:%M:%S}Z - {:%Y-%m-%dT%H:%M:%S}Z baz".format(two_hours_before_utc, one_hour_before_utc))

        code, out, err = self.t("get dom.tracked.ids {:%Y-%m-%dT%H:%M:%S}Z - {:%Y-%m-%dT%H:%M:%S}Z".format(five_hours_before_utc, two_hours_before_utc))
        self.assertEqual("@3 @2 \n", out)

    def test_dom_tracked_ids_filtered_by_tag(self):
        """Test 'dom.tracked.ids' filtered by tag"""
        now_utc = datetime.now(timezone.utc)
        one_hour_before_utc = now_utc - timedelta(hours=1)
        two_hours_before_utc = now_utc - timedelta(hours=2)
        three_hours_before_utc = now_utc - timedelta(hours=3)
        four_hours_before_utc = now_utc - timedelta(hours=4)
        five_hours_before_utc = now_utc - timedelta(hours=5)

        self.t("track {:%Y-%m-%dT%H:%M:%S}Z - {:%Y-%m-%dT%H:%M:%S}Z foo".format(five_hours_before_utc, four_hours_before_utc))
        self.t("track {:%Y-%m-%dT%H:%M:%S}Z - {:%Y-%m-%dT%H:%M:%S}Z bar".format(three_hours_before_utc, two_hours_before_utc))
        self.t("track {:%Y-%m-%dT%H:%M:%S}Z - {:%Y-%m-%dT%H:%M:%S}Z foo baz".format(two_hours_before_utc, one_hour_before_utc))

        code, out, err = self.t("get dom.tracked.ids foo")
        self.assertEqual("@3 @1 \n", out)

    def test_dom_tracked_N_tag_count_zero(self):
        """Test 'dom.tracked.N.tag.count' with zero tags"""
        self.t("track :yesterday one two")
        self.t("start")

        code, out, err = self.t("get dom.tracked.1.tag.count")
        self.assertEqual('0\n', out)

    def test_dom_tracked_N_tag_count_two(self):
        """Test 'dom.tracked.N.tag.count' with two tags"""
        self.t("track :yesterday one two")
        self.t("start")

        code, out, err = self.t("get dom.tracked.2.tag.count")
        self.assertEqual('2\n', out)

    def test_dom_tracked_N_tag_N_none(self):
        """Test 'dom.tracked.N.tag.N' with no data"""
        self.t("track :yesterday one two")
        self.t("start")

        code, out, err = self.t.runError("get dom.tracked.1.tag.1")
        self.assertIn("DOM reference 'dom.tracked.1.tag.1' is not valid.", err)

    def test_dom_tracked_N_tag_N_two(self):
        """Test 'dom.tracked.N.tag.N' with two tags"""
        self.t("track :yesterday one two")
        self.t("start")

        code, out, err = self.t("get dom.tracked.2.tag.2")
        self.assertEqual('two\n', out)

    def test_dom_tracked_N_start_inactive(self):
        """Test 'dom.tracked.N.start' with no active track"""
        self.t("track :yesterday one two")
        self.t("start")

        code, out, err = self.t.runError("get dom.tracked.3.start")
        self.assertIn("DOM reference 'dom.tracked.3.start' is not valid.", err)

    def test_dom_tracked_N_start_active(self):
        """Test 'dom.tracked.N.start' with active track"""
        self.t("track :yesterday one two")
        self.t("start")

        code, out, err = self.t("get dom.tracked.1.start")
        self.assertRegex(out, r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}')

    def test_dom_tracked_N_end_invalid(self):
        """Test 'dom.tracked.N.end' with no active track"""
        self.t("track :yesterday one two")
        self.t("start")

        code, out, err = self.t.runError("get dom.tracked.3.end")
        self.assertIn("DOM reference 'dom.tracked.3.end' is not valid.", err)

    def test_dom_tracked_N_end_inactive(self):
        """Test 'dom.tracked.N.end' with active track"""
        self.t("track :yesterday one two")
        self.t("start")

        code, out, err = self.t("get dom.tracked.2.end")
        self.assertRegex(out, r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}')

    def test_dom_tracked_N_end_active(self):
        """Test 'dom.tracked.N.end' with active track"""
        self.t("track :yesterday one two")
        self.t("start")

        code, out, err = self.t("get dom.tracked.1.end")
        self.assertEqual('\n', out)

    def test_dom_tracked_N_duration_inactive(self):
        """Test 'dom.tracked.N.duration' of closed track"""
        self.t("track :yesterday one two")
        self.t("start")

        code, out, err = self.t("get dom.tracked.2.duration")
        self.assertRegex(out, r'P1D')

    def test_dom_tracked_N_duration_active(self):
        """Test 'dom.tracked.N.duration' with open track"""
        self.t("track :yesterday one two")
        self.t("start")

        code, out, err = self.t("get dom.tracked.1.duration")
        self.assertRegex(out, r'PT\d+S')

    def test_dom_tracked_N_json_inactive(self):
        """Test 'dom.tracked.N.json' of closed track"""
        self.t("track :yesterday one two")
        self.t("start")

        code, out, err = self.t("get dom.tracked.2.json")
        self.assertRegex(out, r'{"id":2,"start":"\d{8}T\d{6}Z","end":"\d{8}T\d{6}Z","tags":\["one","two"\]}')

    def test_dom_tracked_N_json_active(self):
        """Test 'dom.tracked.N.json' of open track"""
        self.t("track :yesterday one two")
        self.t("start")

        code, out, err = self.t("get dom.tracked.1.json")
        self.assertRegex(out, r'{"id":1,"start":"\d{8}T\d{6}Z"}')


class TestDOMRC(TestCase):
    def setUp(self):
        """Executed before each test in the class"""
        self.t = Timew()

    def test_dom_rc_missing(self):
        """Test 'dom.rc.missing' with no value"""
        self.t("get dom.rc.missing")

    def test_dom_rc_present(self):
        """Test 'dom.rc.debug'"""
        self.t("get dom.rc.debug")


if __name__ == "__main__":
    from simpletap import TAPTestRunner

    unittest.main(testRunner=TAPTestRunner())
