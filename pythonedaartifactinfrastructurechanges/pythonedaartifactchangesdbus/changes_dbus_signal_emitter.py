"""
pythonedaartifactinfrastructurepyprojectversioning/pythonedaartifactpyprojectversioningdbus/nix_flake_versioning_dbus_signal_emitter.py

This file defines the PyprojectVersioningDbusSignalEmitter class.

Copyright (C) 2023-today rydnr's pythoneda-artifact-infrastructure/pyproject-versioning

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
"""
from dbus_next import BusType
from pythoneda.event import Event
from pythonedaartifacteventversioning.version_created import VersionCreated
from pythonedaartifacteventversioning.version_requested import VersionRequested
from pythonedaartifacteventinfrastructureversioning.pythonedaartifacteventversioningdbus.dbus_version_created import DbusVersionCreated
from pythonedaartifacteventinfrastructureversioning.pythonedaartifacteventversioningdbus.dbus_version_requested import DbusVersionRequested
from pythonedainfrastructure.pythonedadbus.dbus_signal_emitter import DbusSignalEmitter
from typing import Dict

class PyprojectVersioningDbusSignalEmitter(DbusSignalEmitter):

    """
    A Port that emits Versioning events as d-bus signals.

    Class name: PyprojectVersioningDbusSignalEmitter

    Responsibilities:
        - Connect to d-bus.
        - Emit Versioning events as d-bus signals on behalf of PyprojectVersioning.

    Collaborators:
        - PythonEDA: Requests emitting events.
    """
    def __init__(self):
        """
        Creates a new PyprojectVersioningDbusSignalEmitter instance.
        """
        super().__init__()

    def emitters(self) -> Dict:
        """
        Retrieves the configured event emitters.
        :return: A dictionary with the event class name as key, and a dictionary as value. Such dictionary must include the following entries:
          - "interface": the event interface,
          - "busType": the bus type,
          - "transformer": a function capable of transforming the event into a string.
          - "signature": a function capable of returning the types of the event parameters.
        :rtype: Dict
        """
        result = {}
        version_requested_key, version_requested_config = self.emitter_for_VersionRequested()
        result[version_requested_key] = version_requested_config
        return result

    def emitter_for_VersionRequested(self) -> Dict:
        """
        Retrieves the event emitter configuration for VersionRequested.
        :return: A tuple: the event class name, and a that dictionary must include the following entries:
          - "interface": the event interface,
          - "busType": the bus type,
          - "transformer": a function capable of transforming the event into a string.
          - "signature": a function capable of returning the types of the event parameters.
        :rtype: tuple
        """
        key = self.fqdn_key(VersionRequested)
        return key, {
                "interface": DbusVersionRequested,
                "busType": BusType.SYSTEM,
                "transformer": DbusVersionRequested.transform_VersionRequested,
                "signature": DbusVersionRequested.signature_for_VersionRequested
            }

