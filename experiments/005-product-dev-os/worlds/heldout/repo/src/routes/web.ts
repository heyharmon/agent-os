import { Router } from "express";
import { VehicleController } from "../controllers/VehicleController";
import { VehicleService } from "../services/VehicleService";
import { requireAuth } from "../middleware/requireAuth";

// Routes for the fleet maintenance scheduler. Auth is handled by the
// express-session middleware (see conventions/auth.md). Every route is
// owner-scoped: an operator only sees depots/vehicles they own.
const router = Router();
const vehicles = new VehicleController(new VehicleService());

router.use(requireAuth);
router.get("/depots/:depotId/vehicles", (req, res) => vehicles.index(req, res));
router.post("/depots/:depotId/vehicles", (req, res) => vehicles.store(req, res));

export default router;
